module Spree
  CheckoutController.class_eval do

    def paypal_payment
      load_order
      opts = all_opts(@order, params[:payment_method_id], 'payment')

      if payment_method.preferred_cart_checkout
        opts.merge!(shipping_options)
      else
        opts.merge!(address_options(@order))
      end

      opts = balance_numbers(@order, opts)

      @gateway = paypal_gateway

      if Spree::Config[:auto_capture]
        @ppx_response = @gateway.setup_purchase(opts[:money], opts)
      else
        @ppx_response = @gateway.setup_authorization(opts[:money], opts)
      end

      unless @ppx_response.success?
        gateway_error(@ppx_response)
        redirect_to edit_order_checkout_url(@order, :state => "payment")
        return
      end

      redirect_to(@gateway.redirect_url_for(@ppx_response.token, :review => payment_method.preferred_review))
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)
      redirect_to :back
    end

    def paypal_finish
      load_order

      opts = { :token => params[:token], :payer_id => params[:PayerID] }.merge all_opts(@order, params[:payment_method_id], 'payment' )
      gateway = paypal_gateway

      total = balance_numbers(@order, opts)[:money]

      method = Spree::Config[:auto_capture] ? :purchase : :authorize
      ppx_auth_response = gateway.send(method, total, opts)
      # ppx_auth_response = gateway.send(method, ((@order.total/exchange_rate + 0.01)*100).to_i, opts)

      paypal_account = Spree::PaypalAccount.find_by_payer_id(params[:PayerID])

      payment = @order.payments.create(
        :amount => ppx_auth_response.params["gross_amount"].to_f * exchange_rate,
        :source => paypal_account,
        :source_type => 'Spree::PaypalAccount',
        :payment_method_id => params[:payment_method_id],
        :response_code => ppx_auth_response.authorization,
        :avs_response => ppx_auth_response.avs_result["code"])

      payment.started_processing!

      record_log payment, ppx_auth_response

      if ppx_auth_response.success?
        #confirm status
        case ppx_auth_response.params["payment_status"]
        when "Completed"
          payment.complete!
        when "Pending"
          payment.pend!
        else
          payment.pend!
          Rails.logger.error "Unexpected response from PayPal Express"
          Rails.logger.error ppx_auth_response.to_yaml
        end

        @order.update_attributes({:state => "complete", :completed_at => Time.now}, :without_protection => true)

        state_callback(:after) # So that after_complete is called, setting session[:order_id] to nil

        # Since we dont rely on state machine callback, we just explicitly call this method for spree_store_credits
        if @order.respond_to?(:consume_users_credit, true)
          @order.send(:consume_users_credit)
        end

        @order.finalize!
        flash[:notice] = I18n.t(:order_processed_successfully)
        flash[:commerce_tracking] = "true"
        redirect_to completion_route
      else
        payment.failure!
        order_params = {}
        gateway_error(ppx_auth_response)

        #Failed trying to complete pending payment!
        redirect_to edit_order_checkout_url(@order, :state => "payment")
      end
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)
      redirect_to edit_order_url(@order)
    end

    private

    def order_opts(order, payment_method_id, stage)
      items = order.line_items.map do |item|
        price = (item.price/exchange_rate * 100).to_i # convert for gateway
        { :name        => item.variant.product.name.gsub(/<\/?[^>]*>/, ""),
          :description => (item.variant.product.description[0..120].gsub(/<\/?[^>]*>/, "") if item.variant.product.description),
          :number      => item.variant.sku,
          :quantity    => item.quantity,
          :amount      => price,
          :weight      => item.variant.weight,
          :height      => item.variant.height,
          :width       => item.variant.width,
          :depth       => item.variant.weight }
        end

      credits = order.adjustments.eligible.map do |credit|
        if credit.amount < 0.00
          { :name        => credit.label,
            :description => credit.label,
            :sku         => credit.id,
            :quantity    => 1,
            :amount      => (credit.amount/exchange_rate*100).to_i }
        end
      end

      credits_total = 0
      credits.compact!
      if credits.present?
        items.concat credits
        credits_total = credits.map {|i| i[:amount] * i[:quantity] }.sum
      end

      if payment_method.preferred_cart_checkout and (order.shipping_method.blank? or order.ship_total == 0)
        shipping_cost  = shipping_options[:shipping_options].first[:amount]/exchange_rate
        order_total    = (order.total/exchange_rate * 100 + (shipping_cost)).to_i
        shipping_total = (shipping_cost).to_i
      else
        order_total    = (order.total/exchange_rate * 100).to_i
        shipping_total = (order.ship_total/exchange_rate * 100).to_i
      end

      opts = { :return_url        => paypal_confirm_order_checkout_url(order, :payment_method_id => payment_method_id),
               :cancel_return_url => edit_order_checkout_url(order, :state => :payment),
               :order_id          => order.number,
               :custom            => order.number,
               :items             => items,
               :subtotal          => ((order.item_total / exchange_rate * 100) + credits_total).to_i,
               :tax               => ((order.tax_total / exchange_rate + (order.tax_total > 0 ? 0.01 : 0))* 100).to_i,
               :shipping          => shipping_total,
               :money             => order_total,
               :max_amount        => (order.total/exchange_rate * 300).to_i}

      if stage == "checkout"
        opts[:handling] = 0

        opts[:callback_url] = spree.root_url + "paypal_express_callbacks/#{order.number}"
        opts[:callback_timeout] = 3
      elsif stage == "payment"
        #hack to add float rounding difference in as handling fee - prevents PayPal from rejecting orders
        #because the integer totals are different from the float based total. This is temporary and will be
        #removed once Spree's currency values are persisted as integers (normally only 1c)
        if payment_method.preferred_cart_checkout
          opts[:handling] = 0
        else
          opts[:handling] = (order.total/exchange_rate() * 100).to_i - opts.slice(:subtotal, :tax, :shipping).values.sum
        end
      end
      opts
    end

    def shipping_options
      # Uses users address if exists (from spree_address_book or custom implementation), if not uses first shipping method.
      if spree_current_user.present? && spree_current_user.respond_to?(:addresses) && spree_current_user.addresses.present?
        estimate_shipping_for_user
        shipping_default = @rate_hash_user.map.with_index do |shipping_method, idx|
          if @order.shipping_method_id
            default = (@order.shipping_method_id == shipping_method.id)
          else
            default = (idx == 0)
          end
          {
            :default => default,
            :name    => shipping_method.name,
            :amount  => (shipping_method.cost*100).to_i
          }
        end
      else
        shipping_method = @order.shipping_method_id ? ShippingMethod.find(@order.shipping_method_id) : ShippingMethod.all.first
        shipping_default = [{ :default => true,
                              :name => shipping_method.name,
                              :amount => ((shipping_method.calculator.compute(@order).to_f)/exchange_rate * 100).to_i }]
      end

      {
        :callback_url      => spree.root_url + "paypal_shipping_update",
        :callback_timeout  => 6,
        :callback_version  => '61.0',
        :shipping_options  => shipping_default
      }
    end

    def balance_numbers(order, opts)
      if payment_method.preferred_cart_checkout and (order.shipping_method.blank? or order.ship_total == 0)
        shipping_cost  = shipping_options[:shipping_options].first[:amount] / exchange_rate
        shipping_total = (shipping_cost).to_i
      else
        shipping_total = (order.ship_total / exchange_rate * 100).to_i
      end

      if opts[:shipping] < shipping_total
        opts[:shipping] += (shipping_total - opts[:shipping])
        opts[:money] += (shipping_total - opts[:shipping])
        opts[:shipping_options].first[:amount] = opts[:shipping] if opts[:shipping_options]
      end


      while order.total > opts[:money] * exchange_rate || ((opts[:items].map{ |item| item[:amount]*item[:quantity] }.sum + opts[:shipping]) != opts[:money])
        opts[:items].first[:amount] += 1
        opts[:money] = opts[:items].map{ |item| item[:amount]*item[:quantity] }.sum + opts[:shipping]
      end

      opts[:subtotal] = opts[:items].map{ |item| item[:amount]*item[:quantity] }.sum if opts[:subtotal] != opts[:items].map{ |item| item[:amount]*item[:quantity] }.sum
      opts
    end

    def exchange_rate
      Spree::Config[:usd_exchange_rate].to_f
    end
  end
end

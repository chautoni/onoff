Spree::Core::Search::Base.class_eval do
  def retrieve_products
    @products_scope = get_base_scope
    curr_page = page || 1
    if (@properties[:tag])
      @products = @products_scope.tagged_with(@properties[:tag])
    else
      @products = @products_scope.includes([:master => :prices])
      unless Spree::Config.show_products_without_price
        @products = @products.where("spree_prices.amount IS NOT NULL").where("spree_prices.currency" => current_currency)
      end
    end
    @products = @products.page(curr_page).per(per_page)
  end

  def prepare(params)
    @properties[:taxon] = params[:taxon].blank? ? nil : Spree::Taxon.find(params[:taxon])
    @properties[:keywords] = params[:keywords]
    @properties[:search] = params[:search]

    per_page = params[:per_page].to_i
    @properties[:per_page] = per_page > 0 ? per_page : Spree::Config[:products_per_page]
    @properties[:page] = (params[:page].to_i <= 0) ? 1 : params[:page].to_i
    @properties[:tag] = params[:tag]
  end
end


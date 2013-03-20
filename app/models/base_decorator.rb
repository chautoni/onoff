Spree::Core::Search::Base.class_eval do
  def retrieve_products
    @products_scope = get_base_scope
    curr_page = page || 1
    @products = @products_scope.includes([:master => :prices])
    unless Spree::Config.show_products_without_price
      @products = @products.where("spree_prices.amount IS NOT NULL").where("spree_prices.currency" => current_currency)
    end
    filter_products
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
    @properties[:color] = params[:color]
    @properties[:brand] = params[:brand]
    if params[:price].present? && Spree::Product::PRICE_RANGE_SQLS.keys.include?(params[:price])
      @properties[:price] = Spree::Product::PRICE_RANGE_SQLS[params[:price]]
    end
  end

  def filter_products
    @products = @products.tagged_with(@properties[:tag]) if @properties[:tag].present?
    @products = @products.joins(:variants => :option_values).where('spree_option_values.id = ?', @properties[:color]) if @properties[:color].present?
    @products = @products.joins(taxons: :taxonomy).where('spree_taxonomies.id = ?', @properties[:brand]) if @properties[:brand].present?
    @products = @products.joins(:master => :prices).where("spree_prices.currency = ? and spree_prices.amount #{@properties[:price]}", Spree::Config.currency) if @properties[:price].present?
  end
end


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
    @properties[:variants] = []
    @properties[:variants] += params[:colors] if params[:colors].is_a? Array
    @properties[:variants] += params[:sizes] if params[:sizes].is_a? Array
    @properties[:taxons] = []
    @properties[:taxons] += params[:branches] if params[:branches].is_a? Array
    @properties[:taxons] += params[:collections] if params[:collections].is_a? Array
    if params[:prices].is_a?(Array)
      @properties[:prices] = params[:prices].map do |price_index|
        Spree::Product::PRICE_RANGE_SQLS[price_index]
      end.compact.join(' or ')
    end
  end

  def filter_products
    @products = @products.tagged_with(@properties[:tag]) if @properties[:tag].present?
    @products = @products.joins(:variants => :option_values).where(:'spree_option_values.id' => @properties[:variants].compact.uniq) if @properties[:variants].present?
    @products = @products.joins(:taxons).where(:'spree_taxons.id' => @properties[:taxons].compact.uniq) if @properties[:taxons].present?
    @products = @products.joins(:master => :prices).where("spree_prices.currency = ? and #{@properties[:prices]}", Spree::Config.currency) if @properties[:prices].present?
  end
end


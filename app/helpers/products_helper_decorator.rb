Spree::ProductsHelper.class_eval do
  def breadcrumb(product_name)
    breadcrumb = raw "#{ link_to t('breadcrumb.homepage'), root_path } > #{ link_to t('breadcrumb.online_shop'), products_path } > #{product_name}"
  end
end

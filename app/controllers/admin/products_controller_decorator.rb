# encoding: utf-8

Spree::Admin::ProductsController.class_eval do
  before_filter :load_data, :only => :edit_images
  before_filter :find_product, :only => [:edit_images]
   
  def edit_images
  	respond_with(@product)
  end

  private
  def find_product
  	@product = Spree::Product.where(:permalink => params[:product_id]).first
	  flash[:error] = t(:product_not_found) unless @product
  end
end

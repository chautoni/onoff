# encoding: utf-8

Spree::Admin::ProductsController.class_eval do
  before_filter :load_data, :only => :edit_images
  before_filter :find_product, :only => [:edit_images, :update_images]
   
  def edit_images
  	@color_options = [t(:all)] + @product.colors
    @p_images = @product.images.sort_by { |img| img[:created_at] }
  	respond_with(@product, @p_images)
  end

  def update_images
    if @product.update_attributes(params[:product])
      flash[:success] = t(:update_product_success)
    else
      flash[:error] = t(:update_product_fail)
    end
    redirect_to admin_product_images_url(@product)  
  end

  private
  def find_product
  	@product = Spree::Product.where(:permalink => params[:product_id]).first
	  flash[:error] = t(:product_not_found) unless @product
  end
end

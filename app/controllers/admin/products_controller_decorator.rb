# encoding: utf-8

Spree::Admin::ProductsController.class_eval do
  before_filter :load_data, :only => :edit_images
  before_filter :find_product, :only => [:edit_images, :update_images]
   
  def edit_images
  	@color_options = [t(:all)] + @product.colors + [t(:new_color)]
    @product_images = @product.images.sort_by { |img| img[:attachment_updated_at] }
  	respond_with(@product, @product_images)
  end

  def update_images
    used_colors = params[:product][:images_attributes].map { |k,v| v }.map { |e| e[:color] }.select{ |c| @product.colors.include?(c) }
    if used_colors.count != used_colors.uniq.count
      flash[:error] = t(:one_color_one_image)
      redirect_to edit_images_admin_product_url(@product)  
    else
      if @product.master.update_attributes(:images_attributes => params[:product][:images_attributes])
        flash[:success] = t(:update_product_success)
      else
        flash[:error] = t(:update_product_fail)
      end
      redirect_to admin_product_images_url(@product)  
    end
  end

  private
  def find_product
  	@product = Spree::Product.where(:permalink => params[:product_id]).first
	  flash[:error] = t(:product_not_found) unless @product
  end
end

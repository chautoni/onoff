# encoding: utf-8

Spree::Admin::ProductsController.class_eval do
  before_filter :load_data, :except => [:update_images]
  before_filter :find_product, :product_colors, :only => [:edit_images, :update_images, :create_image, :add_color]

  def new_products
  end

  def import_products
    if params[:file]
      if Spree::Product.support_for_import(params[:file])
        Spree::Product.import(params[:file])
        redirect_to admin_products_path, notice: t(:product_imported)
      else
        redirect_to new_products_path
        flash[:error] = t(:file_ext_not_support_for_import)
      end
    else
      redirect_to new_products_path
      flash[:error] = t(:please_choose_a_file_to_import_product)
    end
  end

  def edit_images
    respond_with(@product, @product_images)
  end

  def update_images
    used_colors = params[:product][:images_attributes].map { |k,v| v }.map { |e| [e[:color], e[:_destroy]] }.select{ |c| (c[1] != 1) && @product.colors.include?(c[0]) }
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

  def create_image
    @image = @product.images.create(params[:image])
    respond_to do |format|
      format.js
    end
  end

  def add_color
    @variant = @product.variants.new
    @variant.set_option_value('color', params[:color])
    respond_to do |format|
      format.js
    end
  end

  private
  def find_product
    @product = Spree::Product.where(:permalink => params[:product_id]).first
    if @product
      @product_images = @product.images.sort_by { |img| img[:attachment_updated_at] }
    else
      flash[:error] = t(:product_not_found)
    end
  end

  def product_colors
    @color_options = [t(:all)] + @product.colors
  end
end

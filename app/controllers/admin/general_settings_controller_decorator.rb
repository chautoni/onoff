Spree::Admin::GeneralSettingsController.class_eval do
  before_filter :load_slideshow, :only => [:homepage_slideshow, :edit_homepage_slideshow, :update_homepage_slideshow]

  def homepage_slideshow
  end

  def edit_homepage_slideshow
  end

  def update_homepage_slideshow
  	params[:slide].each do |id, attributes|
  		slide = Slide.find id
  		if attributes["_destroy"] == "1"
  			slide.destroy
  		else
  			slide.update_attributes(attributes.reject{ |k,v| k == "_destroy" })
  		end
  	end
  	redirect_to list_admin_homepage_slideshow_path
  end

  def create_slide
  	@slide = Slide.new
  	@slide.build_image(params[:slide][:image])
  	@slide.save
  	respond_to do |format|
  		format.js
  	end
  end

  private
  def load_slideshow
  	@slideshow = Slide.order('slide_order asc')
  end
end

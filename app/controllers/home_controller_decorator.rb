Spree::HomeController.class_eval do
  def index
    @slideshow = Slide.order('slide_order asc')
    render :layout => 'spree/layouts/homepage_layout'
  end
end

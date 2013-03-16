Spree::HomeController.class_eval do
  def index
    @slideshow = Slide.order('slide_order asc')
  end
end

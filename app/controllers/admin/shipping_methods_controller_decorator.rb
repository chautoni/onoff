Spree::Admin::ShippingMethodsController.class_eval do
  before_filter :asia_zone_id

  private
  def asia_zone_id
    @asia_id = Spree::Zone.find_by_name("Asia").try(&:id)
  end
end

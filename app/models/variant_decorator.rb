Spree::Variant.class_eval do
  accepts_nested_attributes_for :images, :allow_destroy => true
  accepts_nested_attributes_for :option_values, :allow_destroy => true
  attr_accessible :images, :images_attributes, :count_on_hand, :is_master
  validate :sku, :presence => true

  before_save :assign_sku

  private
  def assign_sku
  	self.sku = "#{self.product.product_sku}#{self.option_value('color')}#{self.option_value('size')}"
  end
end

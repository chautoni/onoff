Spree::Variant.class_eval do
	accepts_nested_attributes_for :images, :allow_destroy => true
	attr_accessible :images, :images_attributes
end

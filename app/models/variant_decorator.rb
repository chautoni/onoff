Spree::Variant.class_eval do
	has_many :images, :as => :viewable, :class_name => Spree::Image, :dependent => :destroy
	accepts_nested_attributes_for :images, :allow_destroy => true
	attr_accessible :images, :images_attributes
end

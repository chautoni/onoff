class Slide < ActiveRecord::Base
	has_one :image, :as => :viewable, :class_name => Spree::Image, :dependent => :destroy
	accepts_nested_attributes_for :image, :allow_destroy => true
  attr_accessible :slide_order, :image
  
  validates :image, :presence => true
end

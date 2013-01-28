Spree::Product.class_eval do
	has_many :images, :as => :viewable, :class_name => Spree::Image, :dependent => :destroy
	accepts_nested_attributes_for :images, :allow_destroy => true
	attr_accessible :images, :images_attributes
	
	DEFAULT_OPTION_TYPES = [COLOR = 'color', SIZE = 'size']
	after_create :assign_color_and_size

  def assign_color_and_size
  	DEFAULT_OPTION_TYPES.each do |type|
  		option_type = Spree::OptionType.find_by_name(type)
  		self.option_types << option_type if option_type
  	end
  end

  def colors
  	self.variants.map { |v| v.option_value('color') }.uniq - [nil]
  end
end

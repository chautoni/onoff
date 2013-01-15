Spree::Product.class_eval do
	DEFAULT_OPTION_TYPES = [COLOR = 'color', SIZE = 'size']
	after_create :assign_color_and_size

  def assign_color_and_size
  	DEFAULT_OPTION_TYPES.each do |type|
  		option_type = Spree::OptionType.find_by_name(type)
  		self.option_types << option_type if option_type
  	end
  end
end

Spree::Product.class_eval do
  acts_as_taggable
	has_many :images, :as => :viewable, :class_name => Spree::Image, :through => :master, :dependent => :destroy
	accepts_nested_attributes_for :images, :allow_destroy => true
	attr_accessible :images, :images_attributes, :tag_list

	DEFAULT_OPTION_TYPES = [COLOR = 'color', SIZE = 'size']
	after_create :assign_color_and_size

  def colors
  	self.variants.map { |v| v.option_value('color') }.uniq.flatten
  end

  def self.all_tags
    self.joins(:tags).pluck('tags.name')
  end

  private

  def assign_color_and_size
    DEFAULT_OPTION_TYPES.each do |type|
      option_type = Spree::OptionType.find_by_name(type)
      self.option_types << option_type if option_type
    end
  end
end

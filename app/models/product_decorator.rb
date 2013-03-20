# encoding: utf-8

Spree::Product.class_eval do
  acts_as_taggable
	has_many :images, :as => :viewable, :class_name => Spree::Image, :through => :master, :dependent => :destroy
	accepts_nested_attributes_for :images, :allow_destroy => true
	attr_accessible :images, :images_attributes, :tag_list, :count_on_hand, :cover_image_id, :product_sku, :featured
  validates :product_sku, :presence => true
  validates :product_sku, :uniqueness => true
  validates :product_sku, :length => { :is => 5 }

  after_create :make_available, :add_product_property_unit

	DEFAULT_OPTION_TYPES = [COLOR = 'color', SIZE = 'size']
  PRICE_RANGES = [
    ['< 100,000', '1'],
    ['100,000 - 200,000', '2'],
    ['> 200,000', '3']
  ]
  PRICE_RANGE_SQLS = {
    '1' => '< 100000',
    '2' => 'between 100000 and 200000',
    '3' => '> 200000'
  }
	after_create :assign_color_and_size
  after_save :assign_cover_image

  def colors
  	self.variants.map { |v| v.option_value_name('color') }.uniq.flatten
  end

  def sizes
    self.variants.map { |v| v.option_value_name('size') }.uniq.flatten
  end

  def cover_image
    image = Spree::Image.find(self.cover_image_id) if self.cover_image_id
    image || self.master.images.first
  end

  def self.all_tags
    self.joins(:tags).pluck('tags.name')
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = [:title, :sku, :unit, :count_on_hand, :price] + spreadsheet.row(1).slice(5, spreadsheet.row(1).size)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      attrs = parse_spreadsheet_row(row)
      product = find_by_name(attrs[:name]) || create(:name => attrs[:name], :price => attrs[:price])

      if attrs[:size] || attrs[:color]
        variant = product.variants.select{ |variant| variant.option_values.map(&:presentation).sort == [attrs[:color], attrs[:size]].sort }.try(:first) || product.variants.new
        variant.set_option_value('color', attrs[:color])
        variant.set_option_value('size', attrs[:size])
        variant.update_attributes(:sku => attrs[:sku], :count_on_hand => attrs[:count_on_hand], :price => attrs[:price] || variant.product.price)
      else
        product.attributes = attrs.reject{ |k,v| [:size, :color, :unit].include?(k) }
        product.save!
      end
      product.set_property('unit', attrs[:unit])
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.support_for_import(file)
    [".csv", ".xls", ".xlsx"].include?(File.extname(file.original_filename))
  end

  def self.parse_spreadsheet_row(row)
    row[:title] = row[:title].split(' ')
    name = row[:title].index('Size') ? row[:title].slice(0, row[:title].index('Size').to_i).join(' ').strip : row[:title].join(' ').strip
    size = row[:title].index('Size') ? row[:title][row[:title].index('Size').to_i + 1] : nil
    color = row[:title].index('Size') ? row[:title].slice(row[:title].index('Size').to_i + 2, row[:title].size - 1).join(' ') : nil
    attrs = {
      :name => name,
      :size => size,
      :color => color,
      :unit => row[:unit],
      :sku => row[:sku],
      :price => row[:price],
      :count_on_hand => row[:count_on_hand]
    }
  end

  private

  def assign_color_and_size
    DEFAULT_OPTION_TYPES.each do |type|
      option_type = Spree::OptionType.find_by_name(type)
      self.option_types << option_type if option_type
    end
  end

  def assign_cover_image
    self.update_attributes(:cover_image_id => self.master.images.first.id) if !self.cover_image_id && self.master.images.first
  end

  def make_available
    self.update_attributes(:available_on => Time.now)
  end

  def add_product_property_unit
    self.properties << Spree::Property.find_by_name('unit')
  end
end

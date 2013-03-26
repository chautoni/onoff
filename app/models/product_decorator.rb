# encoding: utf-8

Spree::Product.class_eval do
  acts_as_taggable
  has_many :images, :as => :viewable, :class_name => Spree::Image, :through => :master, :dependent => :destroy
  accepts_nested_attributes_for :images, :allow_destroy => true
  attr_accessible :images, :images_attributes, :tag_list, :count_on_hand, :cover_image_id, :product_sku, :featured
  validates :product_sku, :presence => true
  validates :product_sku, :uniqueness => true

  after_create :make_available, :add_product_property_unit

  DEFAULT_OPTION_TYPES = [COLOR = 'color', SIZE = 'size']
  PRICE_RANGES = [
    ['< 100,000', '1'],
    ['100,000 - 200,000', '2'],
    ['> 200,000', '3']
  ]
  PRICE_RANGE_SQLS = {
    '1' => 'spree_prices.amount < 100000',
    '2' => 'spree_prices.amount between 100000 and 200000',
    '3' => 'spree_prices.amount > 200000'
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
    image = Spree::Image.find_by_id(self.cover_image_id) if self.cover_image_id
    image || self.master.images.first
  end

  def self.all_tags
    self.joins(:tags).pluck('tags.name')
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = [:title, :sku, :unit, :count_on_hand, :price] + spreadsheet.row(1).slice(5, spreadsheet.row(1).size)
    ActiveRecord::Base.transaction do
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        attrs = parse_spreadsheet_row(row)
        product = find_by_name(attrs[:name]) || create(:name => attrs[:name], :price => attrs[:price], :product_sku => attrs[:sku])

        if attrs[:size] || attrs[:color]
          variant = product.
            variants.
            joins(:option_values => :option_type).
            find('(spree_option_types.name = ? and spree_option_values.name = ?) or (spree_option_types.name = ? and spree_option_values.name = ?)', 'color', attrs[:color], 'size', attrs[:size]) rescue product.variants.new
          unless variant.persisted?
            variant.set_option_value('color', attrs[:color]) if attrs[:color]
            variant.set_option_value('size', attrs[:size]) if attrs[:size]
          end
          variant.update_attributes(:sku => attrs[:sku], :count_on_hand => attrs[:count_on_hand], :price => attrs[:price] || variant.product.price)
        end
        product.set_property('unit', attrs[:unit])
      end
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
    split_title = row[:title].split(' ')
    if size_index = split_title.index('Size')
      name =  split_title[0..(size_index-1)].join(' ')
      size = split_title[size_index + 1]
      color = split_title[(size_index + 2)..(split_title.count - 1)].join(' ')
    end
    attrs = {
      :name => name || row[:title],
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

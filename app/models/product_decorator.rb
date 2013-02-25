# encoding: utf-8

Spree::Product.class_eval do
  acts_as_taggable
	has_many :images, :as => :viewable, :class_name => Spree::Image, :through => :master, :dependent => :destroy
	accepts_nested_attributes_for :images, :allow_destroy => true
	attr_accessible :images, :images_attributes, :tag_list
  after_create :make_available, :add_product_property_unit

	DEFAULT_OPTION_TYPES = [COLOR = 'color', SIZE = 'size']
	after_create :assign_color_and_size

  def colors
  	self.variants.map { |v| v.option_value('color') }.uniq.flatten
  end

  def self.all_tags
    self.joins(:tags).pluck('tags.name')
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = [:title, :sku, :unit, :count_on_hand] + spreadsheet.row(1).slice(4, spreadsheet.row(1).size)
    logs = []
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      attrs = parse_spreadsheet_row(row)
      product = find_by_name(attrs[:name]) || new

      if attrs[:size] || attrs[:color]
        variant = product.variants.select{ |variant| variant.option_values.map(&:presentation).sort == [attrs[:color], attrs[:size]].sort }.try(:first) || product.variants.new
        
        variant.save!
      else
        product.attributes = attrs
        product.save!
      end
      product.set_property('unit', attrs[:unit])
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.support_for_import(file)
    [".csv", ".xls", ".xlsx"].include?(File.extname(file.original_filename))
  end

  def self.parse_spreadsheet_row(row)
    row[:title] = row[:title].split(' ')
    name = row[:title].slice(0, row[:title].index('Size').to_i).join(' ')
    size = row[:title].index('Size') ? row[:title][row[:title].index('Size').to_i + 1] : nil
    color = row[:title].index('Size') ? row[:title].slice(row[:title].index('Size').to_i + 2, row[:title].size - 1) : nil
    attrs = {
      :name => name,
      :size => size,
      :color => color,
      :unit => row[:unit],
      :sku => row[:sku],
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

  def make_available
    self.update_attributes(:available_on => Time.now)
  end

  def add_product_property_unit
    self.properties << Spree::Property.find_by_name('unit')
  end
end

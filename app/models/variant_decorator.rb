Spree::Variant.class_eval do
  accepts_nested_attributes_for :images, :allow_destroy => true
  accepts_nested_attributes_for :option_values, :allow_destroy => true
  attr_accessible :images, :images_attributes, :count_on_hand, :is_master
  validate :sku, :presence => true
  after_save :check_duplicate_variants

  before_save :assign_sku
  after_create :auto_assign_master_price

  def option_value_name(opt_name)
    self.option_values.detect { |o| o.option_type.name == opt_name }.try(:name)
  end

  def options_text
    values = self.option_values.joins(:option_type).order("#{Spree::OptionType.table_name}.position asc")

    values.map! do |ov|
      "#{::I18n.t ov.option_type.name}: #{ov.name}"
    end

    values.to_sentence({ :words_connector => ", ", :two_words_connector => ", " })
  end

  private
  def assign_sku
    self.sku = "#{self.product.product_sku}#{self.option_value('color')}#{self.option_value('size')}"
  end

  def check_duplicate_variants
    variants_options = self.product.variants.map { |v| { :id => v.id, :option_values => { :color => v.option_value('color'), :size => v.option_value('size') } } }
    duplicated_variants = []
    variants_options.each do |v|
      if (variants_options - [v]).map{ |e| e[:option_values] }.include?(v[:option_values])
        id = variants_options.select{ |e| e[:option_values] == v[:option_values] }.map{ |e| e[:id] }.sort.last
        duplicated_variants << Spree::Variant.find_by_id(id) if Spree::Variant.exists?(id: id)
      end
    end
    duplicated_variants.uniq.map(&:destroy)
  end

  def auto_assign_master_price
    update_attributes(:price => product.master.price) if product.master.present?
  end
end

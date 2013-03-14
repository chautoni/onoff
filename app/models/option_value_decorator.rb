Spree::OptionValue.class_eval do
  validates :presentation, :uniqueness => { :scope => :option_type_id }
  validates :name, :uniqueness => { :scope => :option_type_id }

  def sku
    self.presentation
  end
end

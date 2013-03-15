Spree::ReturnAuthorization.class_eval do
  def process_return
    inventory_units.each &:return! if Spree::Config[:track_inventory_levels]
    credit = Spree::Adjustment.new(:amount => amount.abs * -1, :label => I18n.t(:rma_credit))
    credit.source = self
    credit.adjustable = order
    credit.save
    order.return if inventory_units.all?(&:returned?)
  end
end
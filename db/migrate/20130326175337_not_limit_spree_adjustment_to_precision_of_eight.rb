class NotLimitSpreeAdjustmentToPrecisionOfEight < ActiveRecord::Migration
	def up
    change_column :spree_adjustments, :amount, :decimal, :precision => 10, :scale => 2
  end

  def down
    change_column :spree_adjustments, :amount, :decimal, :precision => 8, :scale => 2
  end
end

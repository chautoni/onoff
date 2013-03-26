class NotLimitSpreePaymentsToPrecisionOfEight < ActiveRecord::Migration
  def up
    change_column :spree_payments, :amount, :decimal, :precision => 10, :scale => 2, :null => false
  end

  def down
    change_column :spree_payments, :amount, :decimal, :precision => 8, :scale => 2, :null => false
  end
end

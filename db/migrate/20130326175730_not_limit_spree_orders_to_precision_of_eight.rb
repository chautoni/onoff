class NotLimitSpreeOrdersToPrecisionOfEight < ActiveRecord::Migration
  def up
    change_column :spree_orders, :item_total, :decimal, :precision => 10, :scale => 2, :null => false
    change_column :spree_orders, :total, :decimal, :precision => 10, :scale => 2, :null => false
    change_column :spree_orders, :adjustment_total, :decimal, :precision => 10, :scale => 2, :null => false
    change_column :spree_orders, :payment_total, :decimal, :precision => 10, :scale => 2
  end

  def down
    change_column :spree_orders, :item_total, :decimal, :precision => 8, :scale => 2, :null => false
    change_column :spree_orders, :total, :decimal, :precision => 8, :scale => 2, :null => false
    change_column :spree_orders, :adjustment_total, :decimal, :precision => 8, :scale => 2, :null => false
    change_column :spree_orders, :payment_total, :decimal, :precision => 8, :scale => 2
  end
end

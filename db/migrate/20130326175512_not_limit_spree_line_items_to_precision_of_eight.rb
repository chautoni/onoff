class NotLimitSpreeLineItemsToPrecisionOfEight < ActiveRecord::Migration
  def up
    change_column :spree_line_items, :price, :decimal, :precision => 10, :scale => 2, :null => false
  end

  def down
    change_column :spree_line_items, :price, :decimal, :precision => 8, :scale => 2, :null => false
  end
end

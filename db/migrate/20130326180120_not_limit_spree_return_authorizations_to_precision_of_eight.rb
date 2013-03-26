class NotLimitSpreeReturnAuthorizationsToPrecisionOfEight < ActiveRecord::Migration
  def up
    change_column :spree_return_authorizations, :amount, :decimal, :precision => 10, :scale => 2, :null => false
  end

  def down
    change_column :spree_return_authorizations, :amount, :decimal, :precision => 8, :scale => 2, :null => false
  end
end

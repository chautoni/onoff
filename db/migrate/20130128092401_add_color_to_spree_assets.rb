class AddColorToSpreeAssets < ActiveRecord::Migration
  def change
    add_column :spree_assets, :color, :string
  end
end

class AddColorHexCodeToSpreeOptionValues < ActiveRecord::Migration
  def change
    add_column :spree_option_values, :color_hex_code, :string
  end
end

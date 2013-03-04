class AddCoverImageIdToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :cover_image_id, :int
  end
end

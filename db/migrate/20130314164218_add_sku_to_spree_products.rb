class AddSkuToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :product_sku, :string

    Spree::Product.reset_column_information
    Spree::Product.all.each do |p|
    	sku = p.master.sku.slice(0, 5)
    	unless p.update_attributes(:product_sku => sku)
    		p.update_attributes(:product_sku => ("#{p.id}a" * 5).slice(0, 5))
    	end
    end
  end
end

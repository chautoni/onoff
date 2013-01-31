class CreateSlides < ActiveRecord::Migration
  def change
    create_table :slides do |t|
      t.integer :slide_order

      t.timestamps
    end
  end
end

class AddStoreAndInStockToProducts < ActiveRecord::Migration
  def change
    add_column :products, :stored, :float
    add_column :products, :use_stock, :boolean, default: false
  end
end

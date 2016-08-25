class CopyProductCategoryIdFromSupplierToDistributed < ActiveRecord::Migration
  def change
    products = Product
      .distributed
      .joins(:from_products)
      .where(products: {product_category_id: nil})

    products.find_each do |product|
      product.update_column :product_category_id, product.from_product.product_category_id
    end
  end
end

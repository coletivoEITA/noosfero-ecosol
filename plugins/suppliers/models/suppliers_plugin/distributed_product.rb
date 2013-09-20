class SuppliersPlugin::DistributedProduct < SuppliersPlugin::BaseProduct

  named_scope :from_products_joins, :joins =>
    'INNER JOIN suppliers_plugin_source_products ON ( products.id = suppliers_plugin_source_products.to_product_id ) INNER JOIN products products_2 ON ( suppliers_plugin_source_products.from_product_id = products_2.id )'

  # overhide original
  named_scope :name_like, lambda { |name| { :conditions => ["LOWER(products_2.name) LIKE ?", "%#{name}%"] } }
  named_scope :with_product_category_id, lambda { |id| { :conditions => ['products_2.product_category_id' => id] } }

  validates_presence_of :supplier

  def price
    supplier_price = self.supplier_product ? self.supplier_product.price : nil
    return self['price'] if supplier_price.blank?

    self.price_with_margins supplier_price
  end

  protected

end

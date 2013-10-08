class SuppliersPlugin::DistributedProduct < SuppliersPlugin::BaseProduct

  named_scope :from_products_joins, :joins =>
    'INNER JOIN suppliers_plugin_source_products sources_from_products_products ON ( products.id = sources_from_products_products.to_product_id ) ' +
    'INNER JOIN products from_products_products ON ( sources_from_products_products.from_product_id = from_products_products.id ) ' +
    'INNER JOIN suppliers_plugin_suppliers suppliers ON ( suppliers.id = sources_from_products_products.supplier_id )'

  # overhide original
  named_scope :available, :conditions => ['products.available = ? AND from_products_products.available = ? AND suppliers_plugin_suppliers.active = ?', true, true, true]
  named_scope :name_like, lambda { |name| { :conditions => ["LOWER(from_products_products.name) LIKE ?", "%#{name}%"] } }
  named_scope :with_product_category_id, lambda { |id| { :conditions => ['from_products_products.product_category_id' => id] } }

  validates_presence_of :supplier

  def price
    supplier_price = self.supplier_product ? self.supplier_product.price : nil
    return self['price'] if supplier_price.blank?

    self.price_with_margins supplier_price
  end

  protected

end

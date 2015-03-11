class SuppliersPlugin::DistributedProduct < SuppliersPlugin::BaseProduct

  attr_accessible :from_products

  # overhide original
  scope :available, :conditions => ['products.available = ? AND from_products_products.available = ? AND suppliers_plugin_suppliers.active = ?', true, true, true]
  scope :unavailable, :conditions => ['products.available <> ? OR from_products_products.available <> ? OR suppliers_plugin_suppliers.active <> ?', true, true, true]
  scope :with_available, lambda { |available|
    op = if available then '=' else '<>' end
    cond = if available then 'AND' else 'OR' end
    { :conditions => ["products.available #{op} ? #{cond} from_products_products.available #{op} ? #{cond} suppliers_plugin_suppliers.active #{op} ?", true, true, true] }
  }

  scope :name_like, lambda { |name| { :conditions => ["LOWER(from_products_products.name) LIKE ?", "%#{name}%"] } }
  scope :with_product_category_id, lambda { |id| { :conditions => ['from_products_products.product_category_id = ?', id] } }

  validates_presence_of :supplier

  def price
    supplier_price = self.supplier_product ? self.supplier_product.price : nil
    return self['price'] if supplier_price.blank?

    self.price_with_margins supplier_price
  end

  protected

end

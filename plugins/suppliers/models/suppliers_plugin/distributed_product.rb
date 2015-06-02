class SuppliersPlugin::DistributedProduct < SuppliersPlugin::BaseProduct

  attr_accessible :from_products

  # missed from lib/ext/product.rb because of STI
  attr_accessible :external_id, :price_details

  # overhide original
  scope :available, conditions: ['products.available = ? AND from_products_products.available = ? AND suppliers_plugin_suppliers.active = ?', true, true, true]
  scope :unavailable, conditions: ['products.available <> ? OR from_products_products.available <> ? OR suppliers_plugin_suppliers.active <> ?', true, true, true]
  scope :with_available, lambda { |available|
    op = if available then '=' else '<>' end
    cond = if available then 'AND' else 'OR' end
    where "products.available #{op} ? #{cond} from_products_products.available #{op} ? #{cond} suppliers_plugin_suppliers.active #{op} ?", true, true, true
  }

  scope :name_like, lambda { |name| where "from_products_products.name ILIKE ?", "%#{name}%" }
  scope :with_product_category_id, lambda { |id| where 'from_products_products.product_category_id = ?', id }

  validates_presence_of :supplier

  def price
    supplier_price = self.supplier_product.price if self.supplier_product
    return self.price_with_default if supplier_price.blank?

    self.price_with_margins supplier_price
  end

  protected

end

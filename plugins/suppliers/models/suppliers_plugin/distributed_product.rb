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

  # TODO: maybe move to lib/ext/product
  def supplier_price
    self.supplier_product.price if self.supplier_product
  end

  # Automatic set/get price chaging/applying margins
  # FIXME: this won't work if we have other params, like fixed margin, delivery cost, etc
  def price
    base_price = self.supplier_price
    return super if base_price.blank?

    self.price_with_margins base_price
  end
  def price= value
    return super if value.blank?
    value = value.to_f
    base_price = self.supplier_price
    return super if base_price.blank?

    self.margin_percentage = 100 * (value - base_price) / base_price
    super
  end

  protected

end

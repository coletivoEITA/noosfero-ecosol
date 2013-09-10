class OrdersPlugin::OrderedProduct < Noosfero::Plugin::ActiveRecord

  default_scope :joins => 'INNER JOIN products ON orders_plugin_products.product_id = products.id'

  def self.table_name
    'orders_plugin_products'
  end

  belongs_to :order, :class_name => 'OrdersPlugin::Order', :touch => true
  belongs_to :product, :foreign_key => :product_id

  has_one :profile, :through => :order
  has_one :consumer, :through => :order

  has_many :from_products, :through => :product
  has_many :to_products, :through => :product

  named_scope :confirmed, :conditions => ['orders_plugin_orders.status = ?', 'confirmed'],
    :joins => 'INNER JOIN orders_plugin_orders ON orders_plugin_orders.id = orders_plugin_products.order_id'

  validates_presence_of :order
  validates_presence_of :product
  validates_numericality_of :quantity_asked
  validates_numericality_of :quantity_allocated
  validates_numericality_of :quantity_payed
  validates_numericality_of :price_asked
  validates_numericality_of :price_allocated
  validates_numericality_of :price_payed

  before_save :calculate_prices

  extend CurrencyHelper::ClassMethods
  has_number_with_locale :quantity_asked
  has_number_with_locale :quantity_allocated
  has_number_with_locale :quantity_payed
  has_currency :price_asked
  has_currency :price_allocated
  has_currency :price_asked

  def price_asked
    product.price * quantity_asked
  end
  def price_allocated
    product.price * quantity_allocated
  end
  def price_payed
    product.price * quantity_payed
  end

  protected

  def calculate_prices
    self.price_asked = price_asked
    self.price_allocated = price_allocated
    self.price_payed = price_payed
  end

end

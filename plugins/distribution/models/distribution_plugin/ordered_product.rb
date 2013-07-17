class DistributionPlugin::OrderedProduct < Noosfero::Plugin::ActiveRecord

  belongs_to :order, :class_name => 'DistributionPlugin::Order', :touch => true
  has_one :session, :through => :order
  has_one :node, :through => :order

  belongs_to :offered_product, :foreign_key => :product_id, :class_name => 'DistributionPlugin::OfferedProduct'
  belongs_to :product, :class_name => 'SuppliersPlugin::BaseProduct', :foreign_key => :product_id
  belongs_to :distributed_product, :foreign_key => :product_id

  has_one :supplier, :through => :product
  has_one :consumer, :through => :order

  has_many :from_products, :through => :product
  has_many :to_products, :through => :product

  named_scope :for_session, lambda { |session| {
      :conditions => ['distribution_plugin_sessions.id = ?', session.id],
      :joins => 'INNER JOIN distribution_plugin_orders ON distribution_plugin_ordered_products.order_id = distribution_plugin_orders.id
        INNER JOIN distribution_plugin_sessions ON distribution_plugin_orders.session_id = distribution_plugin_sessions.id'
    }
  }
  named_scope :confirmed, :conditions => ['distribution_plugin_orders.status = ?', 'confirmed'],
    :joins => 'INNER JOIN distribution_plugin_orders ON distribution_plugin_orders.id = distribution_plugin_ordered_products.order_id'

  validates_presence_of :order
  validates_presence_of :product
  validates_numericality_of :quantity_asked
  validates_numericality_of :quantity_allocated
  validates_numericality_of :quantity_payed
  validates_numericality_of :price_asked
  validates_numericality_of :price_allocated
  validates_numericality_of :price_payed

  extend SuppliersPlugin::CurrencyHelper::ClassMethods
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

  before_save :calculate_prices
  def calculate_prices
    self.price_asked = price_asked
    self.price_allocated = price_allocated
    self.price_payed = price_payed
  end

end

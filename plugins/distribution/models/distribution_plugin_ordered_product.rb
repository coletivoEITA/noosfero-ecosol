class DistributionPluginOrderedProduct < ActiveRecord::Base

  belongs_to :order, :class_name => 'DistributionPluginOrder', :touch => true
  has_one :session, :through => :order
  has_one :node, :through => :order

  belongs_to :session_product, :class_name => 'DistributionPluginProduct'
  # same as above
  belongs_to :product, :class_name => 'DistributionPluginProduct', :foreign_key => :session_product_id

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
  validates_presence_of :session_product
  validates_numericality_of :quantity_asked
  validates_numericality_of :quantity_allocated
  validates_numericality_of :quantity_payed
  validates_numericality_of :price_asked
  validates_numericality_of :price_allocated
  validates_numericality_of :price_payed

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

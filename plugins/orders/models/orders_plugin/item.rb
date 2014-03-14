class OrdersPlugin::Item < Noosfero::Plugin::ActiveRecord

  serialize :data

  belongs_to :order, :class_name => 'OrdersPlugin::Order', :touch => true
  belongs_to :product

  has_one :profile, :through => :order
  has_one :consumer, :through => :order

  has_many :from_products, :through => :product
  has_many :to_products, :through => :product

  named_scope :confirmed, :conditions => ['orders_plugin_orders.status = ?', 'confirmed'],
    :joins => 'INNER JOIN orders_plugin_orders ON orders_plugin_orders.id = orders_plugin_items.order_id'

  default_scope :include => [:product]

  validates_presence_of :order
  validates_presence_of :product
  validates_numericality_of :quantity_asked
  validates_numericality_of :quantity_accepted
  validates_numericality_of :quantity_shipped
  validates_numericality_of :price_asked
  validates_numericality_of :price_accepted
  validates_numericality_of :price_shipped

  before_save :calculate_prices

  extend CurrencyHelper::ClassMethods
  has_number_with_locale :quantity_asked
  has_number_with_locale :quantity_accepted
  has_number_with_locale :quantity_shipped
  has_currency :price
  has_currency :price_asked
  has_currency :price_accepted
  has_currency :price_shipped

  def name
    self['name'] || (self.product.name rescue nil)
  end
  def price
    self['price'] || (self.product.price rescue nil)
  end

  STATUS = ['asked', 'accepted', 'shipped']
  ORDER_STATUS_MAP = {
    'asked' => 'confirmed',
    'accepted' => 'accepted',
    'shipped' => 'shipped',
  }

  def modified_state
    if quantity_shipped.present? then 'shipped' elsif quantity_accepted.cpresent? then 'accepted' else 'asked' end
  end
  def modified_order_state
    ORDER_STATUS_MAP[self.modified_state]
  end
  def modified_order_state_message
    I18n.t Order::StatusText[self.modified_order_state]
  end

  def price_asked
    self.price * self.quantity_asked rescue nil
  end
  def price_accepted
    self.price * self.quantity_accepted rescue nil
  end
  def price_shipped
    self.price * self.quantity_shipped rescue nil
  end

  protected

  def calculate_prices
    self.price_asked = self.price_asked
    self.price_accepted = self.price_accepted
    self.price_shipped = self.price_shipped
  end

end

class OrdersPlugin::Item < Noosfero::Plugin::ActiveRecord

  serialize :data

  belongs_to :order, :class_name => 'OrdersPlugin::Order', :touch => true
  belongs_to :sale, :class_name => 'OrdersPlugin::Sale', :foreign_key => :order_id
  belongs_to :purchase, :class_name => 'OrdersPlugin::Purchase', :foreign_key => :order_id

  belongs_to :product

  has_one :profile, :through => :order
  has_one :consumer, :through => :order

  has_many :from_products, :through => :product
  has_many :to_products, :through => :product

  named_scope :ordered, :conditions => ['orders_plugin_orders.status = ?', 'ordered'], :joins => [:order]
  named_scope :for_product, lambda{ |product| {:conditions => {:product_id => product.id}} }

  default_scope :include => [:product]

  validates_presence_of :order
  validates_presence_of :product

  before_save :calculate_prices
  before_create :sync_fields

  StatusAccessMap = {
    'ordered' => :consumer,
    'accepted' => :supplier,
    'separated' => :supplier,
    'delivered' => :supplier,
    'received' => :consumer,
  }
  StatusDataMap = {}; StatusAccessMap.each do |status, access|
    StatusDataMap[status] = "#{access}_#{status}"
  end

  # utility for other classes
  DefineTotals = proc do
    StatusDataMap.each do |status, data|
      quantity = "quantity_#{data}".to_sym
      price = "price_#{data}".to_sym

      self.send :define_method, "total_#{quantity}" do
        self.items.collect(&quantity).inject(0){ |sum,q| sum+q }
      end
      self.send :define_method, "total_#{price}" do
        self.items.collect(&price).inject(0){ |sum,q| sum+q }
      end

      has_number_with_locale "total_#{quantity}"
      has_currency "total_#{price}"
    end
  end

  extend CurrencyHelper::ClassMethods
  has_currency :price
  StatusDataMap.each do |status, data|
    quantity = "quantity_#{data}"
    price = "price_#{data}"

    has_number_with_locale quantity
    has_currency price

    validates_numericality_of quantity, :allow_nil => true
    validates_numericality_of price, :allow_nil => true
  end

  def name
    self['name'] || (self.product.name rescue nil)
  end
  def price
    self['price'] || (self.product.price rescue nil)
  end

  def status
    self.order.status
  end

  def price_consumer_ordered
    self.price * self.quantity_consumer_ordered rescue nil
  end

  protected

  def calculate_prices
    self.price_consumer_ordered = self.price_consumer_ordered
  end

  def sync_fields
    self.name = self.product.name
    self.price = self.product.price
  end

end

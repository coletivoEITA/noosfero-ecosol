# WORKAROUND
require_dependency 'noosfero/plugin/active_record'

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

  before_save :save_calculated_prices
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

      self.send :define_method, "total_#{quantity}" do |items|
        items ||= (self.ordered_items rescue nil) || self.items
        items.collect(&quantity).inject(0){ |sum,q| sum + q.to_f }
      end
      self.send :define_method, "total_#{price}" do |items|
        items ||= (self.ordered_items rescue nil) || self.items
        items.collect(&price).inject(0){ |sum,q| sum + q.to_f }
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

  def self.products_by_suppliers items
    items.group_by(&:supplier).map do |supplier, items|
      products = []
      total_price_consumer_ordered = 0

      items.group_by(&:product).each do |product, items|
        products << product
        product.ordered_items = items
        total_price_consumer_ordered += product.total_price_consumer_ordered items
      end

      [supplier, products, total_price_consumer_ordered]
    end
  end

  # Attributes cached from product
  def name
    self['name'] || (self.product.name rescue nil)
  end
  def price
    self['price'] || (self.product.price rescue nil)
  end
  def unit
    self.product.unit
  end
  def supplier
    self.product.supplier rescue self.order.profile.self_supplier
  end

  def status
    self.order.status
  end

  def quantity_price_data actor_name = :consumer, admin = false
    data = ActiveSupport::OrderedHash.new
    statuses = OrdersPlugin::Order::Statuses
    current = statuses.index self.order.status
    current ||= 0

    statuses.each_with_index do |status, i|
      data_field = OrdersPlugin::Item::StatusDataMap[status]
      access = OrdersPlugin::Item::StatusAccessMap[status]

      data[status] = {
        :flags => {},
        :field => data_field,
        :access => access,
      }

      if self.send("quantity_#{data_field}").present?
        data[status][:quantity] = self.send "quantity_#{data_field}_localized"
        data[status][:price] = self.send "price_#{data_field}_as_currency_number"
        data[status][:flags][:filled] = true
      else
        data[status][:flags][:empty] = true
      end

      # break on the next status
      break if i > current
    end

    statuses.each_index do |i|
      status = statuses[i]
      prev_status = statuses[i-1] unless i.zero?
      next_status = statuses[i+1] if i < statuses.size

      data[status][:flags][:overwritten] = true if next_status and data[next_status][:quantity].present?

      if i == current
        if prev_status and data[status][:quantity].blank?
          data[status][:quantity] = data[prev_status][:quantity]
          data[status][:price] = data[prev_status][:price]
        end

        data[status][:flags][:current] = true
        data[next_status][:flags][:next] = true
        break
      end
    end

    data.each do |status, status_data|
      status_data[:flags][:editable] = status_data[:access] == actor_name and (if admin then status_data[:flags][:next] else self.order.open? end)
    end

    data
  end

  StatusDataMap.each do |status, data|
    quantity = "quantity_#{data}".to_sym
    price = "price_#{data}".to_sym

    self.send :define_method, "calculated_#{price}" do |items|
      self.price * self.send(quantity) rescue nil
    end
  end

  protected

  def save_calculated_prices
    StatusDataMap.each do |status, data|
      price = "price_#{data}".to_sym
      self.send "#{price}=", self.send("calculated_#{price}")
    end
  end

  def sync_fields
    self.name = self.product.name
    self.price = self.product.price
  end

end

class OrdersPlugin::Item < ActiveRecord::Base

  attr_accessible :price, :name, :order, :product

  # flag used by items to compare them with products
  attr_accessor :product_diff

  # should be Order, but can't reference it here so it would create a cyclic reference
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
  StatusDataMap.each do |status, data|
    quantity = "quantity_#{data}".to_sym
    price = "price_#{data}".to_sym

    attr_accessible quantity
    attr_accessible price
  end

  serialize :data

  belongs_to :order, class_name: 'OrdersPlugin::Order', touch: true
  belongs_to :sale, class_name: 'OrdersPlugin::Sale', foreign_key: :order_id
  belongs_to :purchase, class_name: 'OrdersPlugin::Purchase', foreign_key: :order_id

  belongs_to :product
  has_one :supplier, through: :product

  has_one :profile, through: :order
  has_one :consumer, through: :order

  # FIXME: don't work because of load order
  #if defined? SuppliersPlugin
    has_many :from_products, through: :product
    has_many :to_products, through: :product
    has_many :sources_supplier_products, through: :product
    has_many :supplier_products, through: :product
    has_many :suppliers, through: :product
  #end

  scope :ordered, conditions: ['orders_plugin_orders.status = ?', 'ordered'], joins: [:order]
  scope :for_product, lambda{ |product| {conditions: {product_id: product.id}} }

  default_scope include: [:product]

  validates_presence_of :order
  validates_presence_of :product

  before_save :save_calculated_prices
  before_create :sync_fields

  # utility for other classes
  DefineTotals = proc do
    StatusDataMap.each do |status, data|
      quantity = "quantity_#{data}".to_sym
      price = "price_#{data}".to_sym

      self.send :define_method, "total_#{quantity}" do |items=nil|
        items ||= (self.ordered_items rescue nil) || self.items
        items.collect(&quantity).inject(0){ |sum, q| sum + q.to_f }
      end
      self.send :define_method, "total_#{price}" do |items=nil|
        items ||= (self.ordered_items rescue nil) || self.items
        items.collect(&price).inject(0){ |sum, p| sum + p.to_f }
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

    validates_numericality_of quantity, allow_nil: true
    validates_numericality_of price, allow_nil: true
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

  StatusDataMap.each do |status, data|
    quantity = "quantity_#{data}".to_sym
    price = "price_#{data}".to_sym

    define_method "calculated_#{price}" do |items=[]|
      self.price * self.send(quantity) rescue nil
    end
  end

  def quantity_price_data actor_name
    data = {flags: {}}
    statuses = OrdersPlugin::Order::Statuses
    statuses_data = data[:statuses] = {}

    current = statuses.index(self.order.status) || 0
    next_status = self.order.next_status actor_name
    next_index = statuses.index(next_status) || current + 1
    goto_next = actor_name == StatusAccessMap[next_status]

    new_price = nil
    # compare with product
    if self.product_diff and self.product
      if self.price != self.product.price
        new_price = self.product.price
        data[:new_price] = self.product.price_as_currency_number
      end
      data[:flags][:unavailable] = true if not self.product.available
    end

    # Fetch data
    statuses.each_with_index do |status, i|
      data_field = StatusDataMap[status]
      access = StatusAccessMap[status]

      status_data = statuses_data[status] = {
        flags: {},
        field: data_field,
        access: access,
      }

      quantity = self.send "quantity_#{data_field}"
      if quantity.present?
        status_data[:quantity] = self.send "quantity_#{data_field}_localized"
        status_data[:price] = self.send "price_#{data_field}_as_currency_number"
        status_data[:new_price] = quantity * new_price if new_price
        status_data[:flags][:filled] = true
      else
        status_data[:flags][:empty] = true
      end

      if i == current
        status_data[:flags][:current] = true
      elsif i == next_index and goto_next
        status_data[:flags][:admin] = true
      end

      break if (if goto_next then i == next_index else i < next_index end)
    end

    # Set flags according to past/future data
    # Present flags are used as classes
    statuses_data.each.with_index do |(status, status_data), i|
      prev_status_data = statuses_data[statuses[i-1]] unless i.zero?

      if prev_status_data
        if status_data[:quantity] == prev_status_data[:quantity]
          status_data[:flags][:not_modified] = true
        elsif status_data[:flags][:empty]
          # fill with previous status data
          status_data[:quantity] = prev_status_data[:quantity]
          status_data[:price] = prev_status_data[:price]
          status_data[:flags][:filled] = status_data[:flags].delete :empty
          status_data[:flags][:not_modified] = true
        end
      end

    end

    # reverse_each is necessary to set overwritten with intermediate not_modified
    statuses_data.reverse_each.with_index do |(status, status_data), i|
      prev_status_data = statuses_data[statuses[-i-1]]
      if prev_status_data
        if prev_status_data[:flags][:filled] and (status_data[:quantity] != prev_status_data[:quantity] or status_data[:not_modified])
          status_data[:flags][:overwritten] = true
        end
      end
    end

    # Set access
    statuses_data.each_with_index do |(status, status_data), i|
      status_data[:flags][:editable] = true if status_data[:access] == actor_name and (status_data[:flags][:admin] or self.order.open?)
    end

    data
  end

  def calculate_prices price
    self.price = price
    self.save_calculated_prices
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

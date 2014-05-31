class OrdersPlugin::Order < Noosfero::Plugin::ActiveRecord

  Statuses = %w[ordered accepted separated delivered received]
  DbStatuses = %w[draft planned cancelled] + Statuses
  UserStatuses = %w[open forgotten planned cancelled] + Statuses
  StatusText = {}; UserStatuses.map do |status|
    StatusText[status] = "orders_plugin.models.order.statuses.#{status}"
  end

  set_table_name :orders_plugin_orders

  self.abstract_class = true

  belongs_to :profile
  belongs_to :consumer, :class_name => 'Profile'

  has_many :items, :class_name => 'OrdersPlugin::Item', :foreign_key => :order_id, :dependent => :destroy, :order => 'name ASC'
  has_many :products, :through => :items

  belongs_to :supplier_delivery, :class_name => 'DeliveryPlugin::Method'
  belongs_to :consumer_delivery, :class_name => 'DeliveryPlugin::Method'

  named_scope :latest, :order => 'created_at DESC'

  named_scope :draft,     :conditions => {:status => 'draft'}
  named_scope :planned,   :conditions => {:status => 'planned'}
  named_scope :cancelled, :conditions => {:status => 'cancelled'}
  named_scope :not_cancelled, :conditions => ["status <> 'cancelled'"]
  named_scope :ordered,   :conditions => ['ordered_at IS NOT NULL']
  named_scope :confirmed, :conditions => ['ordered_at IS NOT NULL']
  named_scope :accepted,  :conditions => ['accepted_at IS NOT NULL']
  named_scope :separated, :conditions => ['separated_at IS NOT NULL']
  named_scope :delivered, :conditions => ['delivered_at IS NOT NULL']
  named_scope :received,  :conditions => ['received_at IS NOT NULL']

  named_scope :for_profile, lambda{ |profile| {:conditions => {:profile_id => profile.id}} }
  named_scope :for_profile_id, lambda{ |profile_id| {:conditions => {:profile_id => profile_id}} }
  named_scope :for_supplier, lambda{ |profile| {:conditions => {:profile_id => profile.id}} }
  named_scope :for_supplier_id, lambda{ |profile_id| {:conditions => {:profile_id => profile_id}} }
  named_scope :for_consumer, lambda{ |consumer| {:conditions => {:consumer_id => (consumer.id rescue nil)}} }
  named_scope :for_consumer_id, lambda{ |consumer_id| {:conditions => {:consumer_id => consumer_id}} }

  named_scope :months, :select => 'DISTINCT(EXTRACT(months FROM orders_plugin_orders.created_at)) as month', :order => 'month DESC'
  named_scope :years, :select => 'DISTINCT(EXTRACT(YEAR FROM orders_plugin_orders.created_at)) as year', :order => 'year DESC'

  named_scope :by_month, lambda { |month| {
    :conditions => [ 'EXTRACT(month FROM orders_plugin_orders.created_at) <= :month AND EXTRACT(month FROM orders_plugin_orders.created_at) >= :month', { :month => month } ]}
  }
  named_scope :by_year, lambda { |year| {
    :conditions => [ 'EXTRACT(year FROM orders_plugin_orders.created_at) <= :year AND EXTRACT(year FROM orders_plugin_orders.created_at) >= :year', { :year => year } ]}
  }

  named_scope :with_status, lambda { |status|
    {:conditions => {:status => status}}
  }
  named_scope :with_code, lambda { |code|
    {:conditions => {:code => code}}
  }

  validates_presence_of :profile
  validates_inclusion_of :status, :in => DbStatuses

  before_validation :check_status
  after_save :send_notifications

  extend CodeNumbering::ClassMethods
  code_numbering :code, :scope => proc{ self.profile.orders }

  serialize :data

  extend SerializedSyncedData::ClassMethods
  sync_serialized_field :profile do |profile|
    {:name => profile.name, :email => profile.contact_email}
  end
  sync_serialized_field :consumer do |consumer|
    if consumer.blank? then {} else
      {:name => consumer.name, :email => consumer.contact_email, :contact_phone => consumer.contact_phone}
    end
  end
  sync_serialized_field :supplier_delivery
  sync_serialized_field :consumer_delivery
  serialize :payment_data, Hash

  # Aliases needed for terms use
  alias_method :supplier, :profile
  alias_method :supplier_data, :profile_data

  def self.search_scope scope, params
    scope = scope.with_status params[:status] if params[:status].present?
    scope = scope.for_consumer_id params[:consumer_id] if params[:consumer_id].present?
    scope = scope.for_profile_id params[:supplier_id] if params[:supplier_id].present?
    scope = scope.with_code params[:code] if params[:code].present?
    scope = scope.by_month params[:date][:month] if params[:date][:month].present? rescue nil
    scope = scope.by_year params[:date][:year] if params[:date][:year].present? rescue nil
    scope
  end

  def self.products_by_suppliers orders
    OrdersPlugin::Item.products_by_suppliers orders.collect(&:items).flatten
  end

  def orders_name
    raise 'undefined'
  end

  def delivery_methods
    self.profile.delivery_methods
  end

  # All products from the order profile?
  # FIXME reimplement to be generic for consumer/supplier
  def self_supplier?
    return @self_supplier if @self_supplier

    self.items.each do |item|
      return @self_supplier = false unless (item.product.supplier.self? rescue true)
    end
    @self_supplier = true
  end

  def draft?
    self.status == 'draft'
  end
  alias_method :open?, :draft?
  def planned?
    self.status == 'planned'
  end
  def cancelled?
    self.status == 'cancelled'
  end
  def ordered?
    self.ordered_at.present?
  end
  def pre_order?
    not self.ordered?
  end
  alias_method :confirmed?, :ordered?

  def status_on? status
    UserStatuses.index(self.current_status) >= UserStatuses.index(status) rescue false
  end

  def current_status
    return @current_status if @current_status
    return @current_status = 'open' if self.open?
    @current_status = self['status']
  end
  def status_message
    I18n.t StatusText[current_status]
  end

  def next_status
    # if no status was found go to the first (-1 to 0)
    current_index = Statuses.index(self.status) || -1
    Statuses[current_index + 1]
  end

  def situation
    current_index = UserStatuses.index self.current_status || 0
    statuses = []
    UserStatuses.each_with_index do |status, i|
      statuses << status if Statuses.include? status
      break if i >= current_index
    end
    statuses << Statuses.first if statuses.empty?
    statuses
  end

  def may_view? user
    @may_view ||= self.profile.admins.include?(user) or (self.consumer == user)
  end

  # cache is done independent of user as model cache is per request
  def may_edit? user, admin_action = false
    @may_edit ||= (admin_action and self.profile.admins.include?(user)) or (self.open? and self.consumer == user)
  end

  # ShoppingCart format
  def products_list
    hash = {}; self.items.map do |item|
      hash[item.product_id] = {:quantity => item.quantity_consumer_ordered, :name => item.name, :price => item.price}
    end
    hash
  end
  def products_list= hash
    self.items = hash.map do |id, data|
      data[:product_id] = id
      data[:quantity_consumer_ordered] = data.delete(:quantity)
      data[:order] = self
      OrdersPlugin::Item.new data
    end
  end

  extend CurrencyHelper::ClassMethods
  instance_exec &OrdersPlugin::Item::DefineTotals

  # total_price considering last state
  def total_price admin = false
    if not self.pre_order? and admin and status = self.next_status
      self.fill_items_data self.status, status
    else
      status = self.status
    end

    data = OrdersPlugin::Item::StatusDataMap[status] || OrdersPlugin::Item::StatusDataMap[Statuses.first]
    price = "price_#{data}".to_sym

    items ||= (self.ordered_items rescue nil) || self.items
    items.collect(&price).inject(0){ |sum, p| sum + p.to_f }
  end
  has_currency :total_price

  def fill_items_data from_status, to_status, save = false
    return if (Statuses.index(to_status) <= Statuses.index(from_status) rescue true)

    from_data = OrdersPlugin::Item::StatusDataMap[from_status]
    to_data = OrdersPlugin::Item::StatusDataMap[to_status]
    return unless from_data.present? and to_data.present?

    self.items.each do |item|
      # already filled?
      next if (quantity = item.send("quantity_#{to_data}")).present?
      item.send "quantity_#{to_data}=", quantity
      item.send "price_#{to_data}=", item.send("price_#{from_data}")
      item.save if save
    end
  end

  protected

  def check_status
    self.status ||= 'draft'
    # backwards compatibility
    self.status = 'ordered' if self.status == 'confirmed'

    self.fill_items_data self.status_was, self.status, true

    if self.status_on? 'ordered'
      Statuses.each do |status|
        self.send "#{self.status}_at=", Time.now if self.status_was != status and self.status == status
      end
    else
      # for draft, planned, forgotten, cancelled, etc
      Statuses.each do |status|
        self.send "#{status}_at=", nil
      end
    end
  end

  def send_notifications
    return if source == 'shopping_cart_plugin'
    return if (Statuses.index(self.status) <= Statuses.index(self.status_was) rescue false)

    if self.status == 'ordered' and self.status_was != 'ordered'
      OrdersPlugin::Mailer.deliver_order_confirmation self
    elsif self.status == 'cancelled' and self.status_was != 'cancelled'
      OrdersPlugin::Mailer.deliver_order_cancellation self
    end
  end

end

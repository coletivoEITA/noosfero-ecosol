class OrdersPlugin::Order < ActiveRecord::Base

  Statuses = %w[ordered accepted separated delivered received]
  DbStatuses = %w[draft planned cancelled] + Statuses
  UserStatuses = %w[open forgotten planned cancelled] + Statuses
  StatusText = {}; UserStatuses.map do |status|
    StatusText[status] = "orders_plugin.models.order.statuses.#{status}"
  end

  # remember to translate on changes
  ActorData = [
    :name, :email, :contact_phone,
  ]
  DeliveryData = [
    :name, :description,
    :address_line1, :address_line2, :reference,
    :district, :city, :state,
    :postal_code,
  ]
  PaymentData = [
    :method, :change,
  ]

  # copy, for easiness. can't be declared to here to avoid cyclic reference
  StatusDataMap = OrdersPlugin::Item::StatusDataMap
  StatusAccessMap = OrdersPlugin::Item::StatusAccessMap

  StatusesByActor = {
    consumer: StatusAccessMap.map{ |s, a| s if a == :consumer }.compact,
    supplier: StatusAccessMap.map{ |s, a| s if a == :supplier }.compact,
  }

  # workaround for STI
  self.table_name = :orders_plugin_orders
  self.abstract_class = true

  attr_accessible :status, :consumer, :profile, :supplier_delivery_id, :consumer_delivery_id

  belongs_to :profile
  belongs_to :consumer, class_name: 'Profile'

  belongs_to :session, primary_key: :session_id, foreign_key: :session_id, class_name: 'ActiveRecord::SessionStore::Session'

  has_many :items, class_name: 'OrdersPlugin::Item', foreign_key: :order_id, dependent: :destroy, order: 'name ASC'
  has_many :products, through: :items

  belongs_to :supplier_delivery, class_name: 'DeliveryPlugin::Method'
  belongs_to :consumer_delivery, class_name: 'DeliveryPlugin::Method'

  scope :of_session, -> session_id { where session_id: session_id }
  scope :of_user, -> session_id, consumer_id=nil do
    orders = OrdersPlugin::Order.arel_table
    cond = orders[:session_id].eq(session_id)
    cond = cond.or orders[:consumer_id].eq(consumer_id) if consumer_id
    where cond
  end

  scope :latest, order: 'created_at DESC'

  scope :draft,     conditions: {status: 'draft'}
  scope :planned,   conditions: {status: 'planned'}
  scope :cancelled, conditions: {status: 'cancelled'}
  scope :not_cancelled, conditions: ["status <> 'cancelled'"]
  scope :ordered,   conditions: ['ordered_at IS NOT NULL']
  scope :confirmed, conditions: ['ordered_at IS NOT NULL']
  scope :accepted,  conditions: ['accepted_at IS NOT NULL']
  scope :separated, conditions: ['separated_at IS NOT NULL']
  scope :delivered, conditions: ['delivered_at IS NOT NULL']
  scope :received,  conditions: ['received_at IS NOT NULL']

  scope :for_profile, lambda{ |profile| {conditions: {profile_id: profile.id}} }
  scope :for_profile_id, lambda{ |profile_id| {conditions: {profile_id: profile_id}} }
  scope :for_supplier, lambda{ |profile| {conditions: {profile_id: profile.id}} }
  scope :for_supplier_id, lambda{ |profile_id| {conditions: {profile_id: profile_id}} }
  scope :for_consumer, lambda{ |consumer| {conditions: {consumer_id: (consumer.id rescue nil)}} }
  scope :for_consumer_id, lambda{ |consumer_id| {conditions: {consumer_id: consumer_id}} }

  scope :months, select: 'DISTINCT(EXTRACT(months FROM orders_plugin_orders.created_at)) as month', order: 'month DESC'
  scope :years, select: 'DISTINCT(EXTRACT(YEAR FROM orders_plugin_orders.created_at)) as year', order: 'year DESC'

  scope :by_month, lambda { |month| {
    conditions: [ 'EXTRACT(month FROM orders_plugin_orders.created_at) <= :month AND EXTRACT(month FROM orders_plugin_orders.created_at) >= :month', { month: month } ]}
  }
  scope :by_year, lambda { |year| {
    conditions: [ 'EXTRACT(year FROM orders_plugin_orders.created_at) <= :year AND EXTRACT(year FROM orders_plugin_orders.created_at) >= :year', { year: year } ]}
  }

  scope :with_status, lambda { |status|
    {conditions: {status: status}}
  }
  scope :with_code, lambda { |code|
    {conditions: {code: code}}
  }

  validates_presence_of :profile
  # consumer is optional, as orders can be made by unlogged users
  validates_inclusion_of :status, in: DbStatuses

  before_validation :check_status
  after_save :send_notifications

  extend CodeNumbering::ClassMethods
  code_numbering :code, scope: proc{ self.profile.orders }

  serialize :data

  extend SerializedSyncedData::ClassMethods
  sync_serialized_field :profile do |profile|
    {name: profile.name, email: profile.contact_email, contact_phone: profile.contact_phone} if profile
  end
  sync_serialized_field :consumer do |consumer|
    {name: consumer.name, email: consumer.contact_email, contact_phone: consumer.contact_phone} if consumer
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

  def self.products_of orders
    # offered products in case of orders inside cycles
    Product.join(:items).includes(:suppliers).where(orders_plugin_items: {order_id: orders.map(&:id)})
  end

  # for cycle we have situation like this
  #         / Items
  #        /       \ OfferedProduct (column product_id)
  # Order /         \ SourceProduct from DistributedProduct (quantity=1, always)
  #                  \ SourceProduct from Product* (quantity be more than 1 if DistributedProduct is an agregate product)
  # for order outside cycle we have
  #         / Items
  #        /       \ SourceProduct from DistributedProduct (quantity=1, always)
  # Order /         \ SourceProduct from Product* (quantity be more than 1 if DistributedProduct is an agregate product)
  #
  # *suppliers usually don't distribute using cycles, so they only have Product
  #
  def self.supplier_products_by_suppliers orders
    products_by_supplier = {}
    items = OrdersPlugin::Item.where(order_id: orders.map(&:id)).includes({sources_supplier_products: [:supplier, :from_product]})
    items.each do |item|
      if item.sources_supplier_products.present?
        item.sources_supplier_products.each do |source_sp|
          sp = source_sp.from_product
          supplier = source_sp.supplier

          # if it's not yet defined, define it and sum the quantity from aggregated product/product * quantity ordered
          products_by_supplier[supplier] ||= Set.new
          products_by_supplier[supplier] << sp
          sp.quantity_ordered ||= 0
          sp.quantity_ordered += item.quantity_consumer_ordered * source_sp.quantity
        end
      else
        sp = item.product
        supplier = item.order.profile.self_supplier

        products_by_supplier[supplier] ||= Set.new
        products_by_supplier[supplier] << sp
        sp.quantity_ordered ||= 0
        sp.quantity_ordered += item.quantity_consumer_ordered
      end
    end

    products_by_supplier
  end

  def orders_name
    raise 'undefined'
  end

  def delivery_methods
    self.profile.delivery_methods
  end

  def actor_data actor_name
    data = self.send("#{actor_name}_data").select do |k,v|
      OrdersPlugin::Order::ActorData.include? k and v.present?
    end rescue {}
    data = Hash[data]
    data = {} if data.size == 1 and data[:name].present?
    data
  end

  def delivery_data actor_name
    self.send("#{actor_name}_delivery_data").select do |k,v|
      OrdersPlugin::Order::DeliveryData.include? k and v.present?
    end rescue {}
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
    return @current_status if @current_status #cache
    return @current_status = 'open' if self.open?
    @current_status = self['status']
  end
  def status_message
    I18n.t StatusText[current_status]
  end

  def next_status actor_name
    # allow supplier to confirm and receive orders if admin is true
    actor_statuses = if actor_name == :supplier then Statuses else StatusesByActor[actor_name] end
    # if no status was found go to the first (-1 to 0)
    current_index = Statuses.index(self.status) || -1
    next_status = Statuses[current_index + 1]
    next_status if actor_statuses.index next_status rescue false
  end

  def step actor_name
    new_status = self.next_status actor_name
    self.status = new_status if new_status
  end
  def step! actor_name
    # don't crash on errors as some suppliers may have been deleted and this order may not be valid anymore
    self.save if self.step actor_name
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
    @may_view ||= self.profile.admins.include?(user) or ((self.consumer == user)) and self.profile.members.include? user
  end

  # cache is done independent of user as model cache is per request
  def may_edit? user, admin_action = false
    @may_edit ||= (admin_action and self.profile.admins.include?(user)) or (self.open? and self.consumer == user and self.profile.members.include? user)
  end

  def verify_actor? profile, actor_name
    (actor_name == :supplier and self.profile == profile) or (actor_name == :consumer and self.consumer == profile)
  end

  # ShoppingCart format
  def products_list
    hash = {}; self.items.map do |item|
      hash[item.product_id] = {quantity: item.quantity_consumer_ordered, name: item.name, price: item.price}
    end
    hash
  end
  def products_list= hash
    self.items = hash.map do |id, data|
      data[:quantity_consumer_ordered] = data.delete(:quantity)
      i = OrdersPlugin::Item.new data
      i.product_id = id
      i.order = self
      i
    end
  end

  def items_summary
    self.items.map{ |item| "#{item.name} (#{item.quantity_consumer_ordered_localized})" }.join ', '
  end

  extend CurrencyHelper::ClassMethods
  instance_exec &OrdersPlugin::Item::DefineTotals

  # total_price considering last state
  def total_price actor_name, admin = false
    if not self.pre_order? and admin and status = self.next_status(actor_name)
      self.fill_items_data self.status, status
    else
      status = self.status
    end

    data = StatusDataMap[status] || StatusDataMap[Statuses.first]
    price = "price_#{data}".to_sym

    items ||= (self.ordered_items rescue nil) || self.items
    items.collect(&price).inject(0){ |sum, p| sum + p.to_f }
  end
  has_currency :total_price

  def fill_items_data from_status, to_status, save = false
    return if (Statuses.index(to_status) <= Statuses.index(from_status) rescue true)

    from_data = StatusDataMap[from_status]
    to_data = StatusDataMap[to_status]
    return unless from_data.present? and to_data.present?

    self.items.each do |item|
      # already filled?
      next if (quantity = item.send "quantity_#{to_data}").present?
      item.send "quantity_#{to_data}=", item.send("quantity_#{from_data}")
      item.send "price_#{to_data}=", item.send("price_#{from_data}")
      item.save if save
    end
  end

  def enable_product_diff
    self.items.each{ |i| i.product_diff = true }
  end

  protected

  def check_status
    self.status ||= 'draft'
    # backwards compatibility
    self.status = 'ordered' if self.status == 'confirmed'

    self.fill_items_data self.status_was, self.status, true
    self.sync_serialized_data if self.status_changed?

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
    # shopping_cart has its notifications
    return if source == 'shopping_cart_plugin'
    # ignore when status is being rewinded
    return if (Statuses.index(self.status) <= Statuses.index(self.status_was) rescue false)
    # dummy suppliers don't notify
    return unless self.profile.visible

    if self.status == 'ordered' and self.status_was != 'ordered'
      OrdersPlugin::Mailer.order_confirmation(self).deliver
    elsif self.status == 'cancelled' and self.status_was != 'cancelled'
      OrdersPlugin::Mailer.order_cancellation(self).deliver
    end
  end

end

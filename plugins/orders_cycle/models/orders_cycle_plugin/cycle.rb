class OrdersCyclePlugin::Cycle < Noosfero::Plugin::ActiveRecord

  Statuses = %w[edition orders purchases receipts separation delivery closing]
  DbStatuses = %w[new] + Statuses
  UserStatuses = Statuses

  StatusActorMap = ActiveSupport::OrderedHash[
    'edition', :supplier,
    'orders', :supplier,
    'purchases', :consumer,
    'receipts', :consumer,
    'separation', :supplier,
    'delivery', :supplier,
    'closing', :supplier,
  ]
  OrderStatusMap = ActiveSupport::OrderedHash[
    'orders', :ordered,
    'purchases', :draft,
    'receipts', :ordered,
    'separation', :accepted,
    'delivery', :separated,
  ]

  belongs_to :profile

  has_many :delivery_options, :class_name => 'DeliveryPlugin::Option', :dependent => :destroy,
    :foreign_key => :owner_id, :conditions => ["delivery_plugin_options.owner_type = 'OrdersCyclePlugin::Cycle'"]
  has_many :delivery_methods, :through => :delivery_options, :source => :delivery_method

  has_many :cycle_orders, :class_name => 'OrdersCyclePlugin::CycleOrder', :foreign_key => :cycle_id, :dependent => :destroy, :order => 'id ASC'

  # cannot use :order because of months/years named_scope
  has_many :sales, :through => :cycle_orders, :source => :sale
  has_many :purchases, :through => :cycle_orders, :source => :purchase

  has_many :cycle_products, :foreign_key => :cycle_id, :class_name => 'OrdersCyclePlugin::CycleProduct', :dependent => :destroy
  has_many :products, :through => :cycle_products, :order => 'products.name ASC',
    :include => [{:from_products => [:from_products, {:sources_from_products => [{:supplier => [{:profile => [:domains]}]}]}]}, {:profile => [:domains]}]

  has_many :consumers, :through => :sales, :source => :consumer, :order => 'name ASC'
  has_many :suppliers, :through => :products, :order => 'suppliers_plugin_suppliers.name ASC', :uniq => true
  has_many :orders_suppliers, :through => :sales, :source => :profile, :order => 'name ASC'

  has_many :from_products, :through => :products, :order => 'name ASC'

  has_many :orders_confirmed, :through => :cycle_orders, :source => :sale, :order => 'id ASC',
    :conditions => ['orders_plugin_orders.ordered_at IS NOT NULL']

  has_many :ordered_suppliers, :through => :orders_confirmed, :source => :suppliers
  has_many :items, :through => :orders_confirmed, :source => :products

  has_many :ordered_offered_products, :through => :orders_confirmed, :source => :offered_products, :uniq => true
  has_many :ordered_distributed_products, :through => :orders_confirmed, :source => :distributed_products, :uniq => true
  has_many :ordered_supplier_products, :through => :orders_confirmed, :source => :supplier_products, :uniq => true

  extend CodeNumbering::ClassMethods
  code_numbering :code, :scope => Proc.new { self.profile.orders_cycles }

  # status scopes
  named_scope :defuncts, :conditions => ["status = 'new' AND created_at < ?", 2.days.ago]
  named_scope :not_new, :conditions => ["status <> 'new'"]
  named_scope :on_orders, lambda {
    {:conditions => ["status = 'orders' AND ( (start <= :now AND finish IS NULL) OR (start <= :now AND finish >= :now) )",
      {:now => DateTime.now}]}
  }
  named_scope :not_on_orders, lambda {
    {:conditions => ["NOT (status = 'orders' AND ( (start <= :now AND finish IS NULL) OR (start <= :now AND finish >= :now) ) )",
      {:now => DateTime.now}]}
  }
  named_scope :open, :conditions => ["status <> 'new' AND status <> 'closing'"]
  named_scope :closing, :conditions => ["status = 'closing'"]
  named_scope :by_status, lambda { |status| { :conditions => {:status => status} } }

  named_scope :months, :select => 'DISTINCT(EXTRACT(months FROM start)) as month', :order => 'month DESC'
  named_scope :years, :select => 'DISTINCT(EXTRACT(YEAR FROM start)) as year', :order => 'year DESC'

  named_scope :by_month, lambda { |month| {
    :conditions => [ 'EXTRACT(month FROM start) <= :month AND EXTRACT(month FROM finish) >= :month', { :month => month } ]}
  }
  named_scope :by_year, lambda { |year| {
    :conditions => [ 'EXTRACT(year FROM start) <= :year AND EXTRACT(year FROM finish) >= :year', { :year => year } ]}
  }
  named_scope :by_range, lambda { |range| {
    :conditions => [ 'start BETWEEN :start AND :finish OR finish BETWEEN :start AND :finish',
      { :start => range.first, :finish => range.last }
    ]}
  }

  validates_presence_of :profile
  validates_presence_of :name, :if => :not_new?
  validates_presence_of :start, :if => :not_new?
  #validates_presence_of :delivery_options, :unless => :new_or_edition?
  validates_inclusion_of :status, :in => DbStatuses, :if => :not_new?
  validates_numericality_of :margin_percentage, :allow_nil => true, :if => :not_new?
  validate :validate_orders_dates, :if => :not_new?
  validate :validate_delivery_dates, :if => :not_new?

  before_validation :step_new
  before_validation :check_status
  before_save :add_products_on_edition_state
  before_create :delay_purge_profile_defuncts

  extend SplitDatetime::SplitMethods
  split_datetime :start
  split_datetime :finish
  split_datetime :delivery_start
  split_datetime :delivery_finish

  serialize :data, Hash

  def name_with_code
    I18n.t('orders_cycle_plugin.models.cycle.code_name') % {
      :code => code, :name => name
    }
  end
  def total_price_consumer_ordered
    self.items.sum :price_consumer_ordered
  end

  def status
    self['status'] = 'closing' if self['status'] == 'closed'
    self['status']
  end

  def step
    self.status = DbStatuses[DbStatuses.index(self.status)+1]
  end
  def step_back
    self.status = DbStatuses[DbStatuses.index(self.status)-1]
  end

  def passed_by? status
    DbStatuses.index(self.status) > DbStatuses.index(status) rescue false
  end

  def new?
    self.status == 'new'
  end
  def not_new?
    self.status != 'new'
  end
  def open?
    !self.closing?
  end
  def closing?
    self.status == 'closing'
  end
  def edition?
    self.status == 'edition'
  end
  def new_or_edition?
    self.status == 'new' or self.status == 'edition'
  end
  def orders?
    now = DateTime.now
    status == 'orders' && ( (self.start <= now && self.finish.nil?) || (self.start <= now && self.finish >= now) )
  end
  def delivery?
    now = DateTime.now
    status == 'delivery' && ( (self.delivery_start <= now && self.delivery_finish.nil?) || (self.delivery_start <= now && self.delivery_finish >= now) )
  end

  def products_for_order
    self.products.unarchived.with_price
  end

  def products_by_suppliers
    self.ordered_offered_products.unarchived.group_by{ |p| p.supplier }.map do |supplier, products|
      total_price_consumer_ordered = 0
      products.each do |product|
        total_price_consumer_ordered += product.total_price_consumer_ordered if product.total_price_consumer_ordered
      end

      [supplier, products, total_price_consumer_ordered]
    end
  end

  def generate_purchases
    return self.purchases if self.purchases.present?

    self.ordered_offered_products.unarchived.group_by{ |p| p.supplier }.map do |supplier, products|
      next unless supplier_product = product.supplier_product

      # can't be created using self.purchases.create!, as if :cycle is set (needed for code numbering), then double CycleOrder will be created
      purchase = OrdersPlugin::Purchase.create! :cycle => self, :consumer => self.profile, :profile => supplier.profile
      products.each do |product|
        purchase.items.create! :order => purchase, :product => product.supplier_product,
          :quantity_consumer_ordered => product.total_quantity_consumer_ordered, :price_consumer_ordered => product.total_price_consumer_ordered
      end
    end

    self.purchases true
  end

  def add_distributed_products
    return if self.products.count > 0
    ActiveRecord::Base.transaction do
      self.profile.distributed_products.unarchived.available.find_each(:batch_size => 20) do |product|
        OrdersCyclePlugin::OfferedProduct.create_from_distributed self, product
      end
    end
  end

  def can_order? user
    profile.members.include? user
  end

  def add_products_job
    @add_products_job ||= Delayed::Job.find_by_id self.data[:add_products_job_id]
  end

  protected

  def add_products_on_edition_state
    return unless self.status_was == 'new'
    job = self.delay.add_distributed_products
    self.data[:add_products_job_id] = job.id
  end

  def step_new
    return if new_record?
    if self.new?
      @was_new = true
      self.step
    end
  end

  def check_status
    # done at #step_new
    return if self.new?

    # step orders to next_status on status change
    return if self.status_was.blank?
    return unless order_status = OrderStatusMap[self.status_was]
    actor_name = StatusActorMap[self.status_was]
    orders_method = if actor_name == :supplier then :sales else :purchases end
    orders = self.send(orders_method).where(:status => order_status.to_s)
    orders.each{ |order| order.step! actor_name }
  end

  def validate_orders_dates
    return if self.new? or self.finish.nil?
    errors.add_to_base(I18n.t('orders_cycle_plugin.models.cycle.invalid_orders_period')) unless self.start < self.finish
  end

  def validate_delivery_dates
    return if self.new? or delivery_start.nil? or delivery_finish.nil?
    errors.add_to_base I18n.t('orders_cycle_plugin.models.cycle.invalid_delivery_peri') unless delivery_start < delivery_finish
    errors.add_to_base I18n.t('orders_cycle_plugin.models.cycle.delivery_period_befor') unless finish <= delivery_start
  end

  def purge_profile_defuncts
    self.class.where(:profile_id => self.profile_id).defuncts.destroy_all
  end

  def delay_purge_profile_defuncts
    self.delay.purge_profile_defuncts
  end

end

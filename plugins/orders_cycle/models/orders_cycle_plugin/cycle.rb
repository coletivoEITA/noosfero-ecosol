class OrdersCyclePlugin::Cycle < Noosfero::Plugin::ActiveRecord

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
    :conditions => ['orders_plugin_orders.status = ?', 'confirmed']

  has_many :ordered_suppliers, :through => :orders_confirmed, :source => :suppliers
  has_many :items, :through => :orders_confirmed, :source => :products

  has_many :ordered_offered_products, :through => :orders_confirmed, :source => :offered_products, :uniq => true
  has_many :ordered_distributed_products, :through => :orders_confirmed, :source => :distributed_products, :uniq => true
  has_many :ordered_supplier_products, :through => :orders_confirmed, :source => :supplier_products, :uniq => true

  extend CodeNumbering::ClassMethods
  code_numbering :code, :scope => Proc.new { self.profile.orders_cycles }

  named_scope :defuncts, :conditions => ["status = 'new' AND created_at < ?", 2.days.ago]
  named_scope :not_new, :conditions => ["status <> 'new'"]
  named_scope :open, lambda {
    {:conditions => ["status = 'orders' AND ( (start <= :now AND finish IS NULL) OR (start <= :now AND finish >= :now) )",
      {:now => DateTime.now}]}
  }
  named_scope :not_open, lambda {
    {:conditions => ["NOT ( ( (start <= :now AND finish IS NULL) OR (start <= :now AND finish >= :now) ) AND status = 'orders' )",
      {:now => DateTime.now}]}
  }

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
  named_scope :by_status, lambda { |status| { :conditions => {:status => status} } }

  named_scope :status_open, :conditions => ["status <> 'closed'"]
  named_scope :status_closed, :conditions => ["status = 'closed'"]

  DbStatuses = %w[new edition orders purchases closed]
  UserStatuses = %w[edition orders purchases]

  validates_presence_of :profile
  validates_presence_of :name, :if => :not_new?
  validates_presence_of :start, :if => :not_new?
  #FIXME only ,
  #validates_presence_of :delivery_options, :unless => :new_or_edition?
  validates_inclusion_of :status, :in => DbStatuses, :if => :not_new?
  validates_numericality_of :margin_percentage, :allow_nil => true, :if => :not_new?
  validate :validate_orders_dates, :if => :not_new?
  validate :validate_delivery_dates, :if => :not_new?

  before_validation :step_new
  after_save :add_products_on_edition_state
  before_create :delay_purge_defuncts

  extend SplitDatetime::SplitMethods
  split_datetime :start
  split_datetime :finish
  split_datetime :delivery_start
  split_datetime :delivery_finish

  def name_with_code
    I18n.t('orders_cycle_plugin.models.cycle.code_name') % {
      :code => code, :name => name
    }
  end
  def total_price_consumer_asked
    self.items.sum :price_consumer_asked
  end
  def total_purchase_price
    #FIXME: wrong!
    self.ordered_supplier_products.sum :price
  end

  def step
    self.status = DbStatuses[DbStatuses.index(self.status)+1]
  end
  def step_back
    self.status = DbStatuses[DbStatuses.index(self.status)-1]
  end
  def passed_by? status
    DbStatuses.index(self.status) > DbStatuses.index(status)
  end
  def new?
    status == 'new'
  end
  def open?
    !closed?
  end
  def closed?
    status == 'closed'
  end
  def edition?
    status == 'edition'
  end
  def new_or_edition?
    status == 'new' or status == 'edition'
  end
  def orders?
    now = DateTime.now
    status == 'orders' && ( (self.start <= now && self.finish.nil?) || (self.start <= now && self.finish >= now) )
  end
  def delivery?
    now = DateTime.now
    status == 'orders' && ( (self.delivery_start <= now && self.delivery_finish.nil?) || (self.delivery_start <= now && self.delivery_finish >= now) )
  end

  def products_for_order
    self.products.unarchived.with_price
  end

  def items_by_suppliers
    self.ordered_offered_products.unarchived.group_by{ |p| p.supplier }.map do |supplier, products|
      total_price_consumer_asked = total_purchase_price = 0
      products.each do |product|
        total_price_consumer_asked += product.total_price_consumer_asked if product.total_price_consumer_asked
        total_purchase_price += product.total_purchase_price if product.total_purchase_price
      end

      [supplier, products, total_price_consumer_asked, total_purchase_price]
    end
  end

  def generate_purchases
    return self.purchases if self.purchases.present?

    self.ordered_offered_products.unarchived.group_by{ |p| p.supplier }.map do |supplier, products|
      # can't be created using self.purchases.create!, as if :cycle is set (needed for code numbering), then double CycleOrder will be created
      purchase = OrdersPlugin::Purchase.create! :cycle => self, :consumer => self.profile, :profile => supplier.profile
      products.each do |product|
        purchase.items.create! :order => purchase, :product => product.supplier_product,
          :quantity_consumer_asked => product.total_quantity_consumer_asked, :price_consumer_asked => product.total_price_consumer_asked
      end
    end

    self.purchases true
  end

  def add_distributed_products
    already_in = self.products.unarchived.all
    ActiveRecord::Base.transaction do
      self.profile.distributed_products.unarchived.available.each do |product|
        p = already_in.find{ |f| f.from_product == product }
        p = OrdersCyclePlugin::OfferedProduct.create_from_distributed self, product unless p
      end
    end
  end

  protected

  def add_products_on_edition_state
    self.add_distributed_products if @was_new
  end

  def step_new
    return if new_record?
    if self.new?
      @was_new = true
      self.step
    end
  end

  def not_new?
    status != 'new'
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

  def purge_defuncts
    self.defuncts.each{ |s| s.destroy }
  end
  def delay_purge_defuncts
    self.delay.purge_defuncts
  end

end

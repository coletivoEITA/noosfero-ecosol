class DistributionPlugin::Order < Noosfero::Plugin::ActiveRecord

  belongs_to :session, :class_name => 'DistributionPlugin::Session'
  has_one :node, :through => :session

  belongs_to :consumer, :class_name => 'DistributionPlugin::Node'

  has_many :suppliers, :through => :session_products, :uniq => true
  has_many :products, :class_name => 'DistributionPlugin::OrderedProduct', :foreign_key => 'order_id', :dependent => :destroy, :include => 'product',
    :order => 'products.name ASC'

  has_many :session_products, :through => :products, :source => :product
  has_many :distributed_products, :through => :session_products, :source => :from_products
  has_many :supplier_products, :through => :distributed_products, :source => :from_products

  has_many :from_products, :through => :products
  has_many :to_products, :through => :products

  belongs_to :supplier_delivery, :class_name => 'DistributionPlugin::DeliveryMethod'
  belongs_to :consumer_delivery, :class_name => 'DistributionPlugin::DeliveryMethod'

  named_scope :for_consumer, lambda { |consumer| {
    :conditions => {:consumer_id => consumer ? consumer.id : nil} }
  }
  named_scope :for_session, lambda { |session| { :conditions => {:session_id => session.id} } }
  named_scope :for_node, lambda { |node| {
      :conditions => ['distribution_plugin_nodes.id = ?', node.id],
      :joins => 'INNER JOIN distribution_plugin_sessions ON distribution_plugin_orders.session_id = distribution_plugin_sessions.id
        INNER JOIN distribution_plugin_nodes ON distribution_plugin_sessions.node_id = distribution_plugin_nodes.id'
    }
  }

  extend CodeNumbering::ClassMethods
  code_numbering :code, :scope => Proc.new { self.session.orders }

  validates_presence_of :session
  validates_presence_of :consumer
  #validates_presence_of :supplier_delivery
  STATUSES = ['draft', 'planned', 'confirmed', 'cancelled']
  validates_inclusion_of :status, :in => STATUSES

  named_scope :draft, :conditions => {:status => 'draft'}
  named_scope :planned, :conditions => {:status => 'planned'}
  named_scope :confirmed, :conditions => {:status => 'confirmed'}
  named_scope :cancelled, :conditions => {:status => 'cancelled'}
  def draft?
    status == 'draft'
  end
  def planned?
    status == 'planned'
  end
  def confirmed?
    status == 'confirmed'
  end
  def cancelled?
    status == 'cancelled'
  end
  def forgotten?
    draft? && !session.orders?
  end
  def open?
    draft? && session.orders?
  end
  def current_status
    return 'forgotten' if forgotten?
    return 'open' if open?
    self['status']
  end

  STATUS_MESSAGE = {
   'open' => 'distribution_plugin.models.order.order_in_progress',
   'forgotten' => 'distribution_plugin.models.order.order_not_confirmed',
   'planned' => 'distribution_plugin.models.order.order_planned',
   'confirmed' => 'distribution_plugin.models.order.order_confirmed',
   'cancelled' => 'distribution_plugin.models.order.order_cancelled',
  }
  def status_message
    I18n.t STATUS_MESSAGE[current_status]
  end

  def delivery?
    session.delivery?
  end

  alias_method :supplier_delivery!, :supplier_delivery
  def supplier_delivery
    supplier_delivery! || session.delivery_methods.first
  end
  def supplier_delivery_id
    self['supplier_delivery_id'] || session.delivery_methods.first.id
  end

  def total_quantity_asked(dirty = false)
    if dirty
      products.collect(&:quantity_asked).inject(0){ |sum,q| sum+q }
    else
      products.sum(:quantity_asked)
    end
  end
  def total_price_asked(dirty = false)
    if dirty
      products.collect(&:price_asked).inject(0){ |sum,q| sum+q }
    else
      products.sum(:price_asked)
    end
  end

  def parcel_quantity_total
    #TODO
    total_quantity_asked
  end
  def parcel_price_total
    #TODO
    total_price_asked
  end

  def products_by_supplier
    self.products.group_by{|p| p.supplier.name}
  end

  extend SuppliersPlugin::CurrencyHelper::ClassMethods
  has_number_with_locale :total_quantity_asked
  has_number_with_locale :parcel_quantity_total
  has_currency :total_price_asked
  has_currency :parcel_price_total

  def code
    I18n.t('distribution_plugin.models.order.sessioncode_ordercode') % {
      :sessioncode => session.code, :ordercode => self['code']
    }
  end

  protected

  before_validation :default_values
  def default_values
    self.status ||= 'draft'
  end

end

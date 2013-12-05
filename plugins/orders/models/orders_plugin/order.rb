class OrdersPlugin::Order < Noosfero::Plugin::ActiveRecord

  belongs_to :profile
  belongs_to :consumer, :class_name => 'Profile'

  has_many :products, :class_name => 'OrdersPlugin::OrderedProduct', :foreign_key => :order_id, :dependent => :destroy,
    :include => [{:product => [{:profile => [:domains]}]}], :order => 'products.name ASC'

  belongs_to :supplier_delivery, :class_name => 'DeliveryPlugin::Method'
  belongs_to :consumer_delivery, :class_name => 'DeliveryPlugin::Method'

  named_scope :for_consumer, lambda { |consumer| {
    :conditions => {:consumer_id => consumer ? consumer.id : nil} }
  }

  extend CodeNumbering::ClassMethods
  code_numbering :code

  validates_presence_of :profile
  #validates_presence_of :supplier_delivery
  STATUSES = ['draft', 'planned', 'confirmed', 'cancelled']
  validates_inclusion_of :status, :in => STATUSES
  before_validation :default_values

  named_scope :draft, :conditions => {:status => 'draft'}
  named_scope :planned, :conditions => {:status => 'planned'}
  named_scope :confirmed, :conditions => {:status => 'confirmed'}
  named_scope :cancelled, :conditions => {:status => 'cancelled'}
  def draft?
    self.status == 'draft'
  end
  def planned?
    self.status == 'planned'
  end
  def confirmed?
    self.status == 'confirmed'
  end
  def cancelled?
    self.status == 'cancelled'
  end
  def current_status
    return 'forgotten' if forgotten?
    return 'open' if open?
    self['status']
  end

  def may_edit? admin_action = false
    self.draft? or admin_action
  end


  STATUS_MESSAGE = {
   'open' => 'orders_plugin.models.order.order_in_progress',
   'forgotten' => 'orders_plugin.models.order.order_not_confirmed',
   'planned' => 'orders_plugin.models.order.order_planned',
   'confirmed' => 'orders_plugin.models.order.order_confirmed',
   'cancelled' => 'orders_plugin.models.order.order_cancelled',
  }
  def status_message
    I18n.t STATUS_MESSAGE[current_status]
  end

  def total_quantity_asked
    self.products.collect(&:quantity_asked).inject(0){ |sum,q| sum+q }
  end
  def total_price_asked
    self.products.collect(&:price_asked).inject(0){ |sum,q| sum+q }
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
    self.products.group_by{ |p| p.supplier.abbreviation_or_name }
  end

  extend CurrencyHelper::ClassMethods
  has_number_with_locale :total_quantity_asked
  has_number_with_locale :parcel_quantity_total
  has_currency :total_price_asked
  has_currency :parcel_price_total

  protected

  def default_values
    self.status ||= 'draft'
  end

end

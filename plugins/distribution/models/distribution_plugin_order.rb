class DistributionPluginOrder < ActiveRecord::Base
  belongs_to :session, :class_name => 'DistributionPluginSession'
  belongs_to :consumer, :class_name => 'DistributionPluginNode'

  has_many :suppliers, :through => :products, :uniq => true
  has_many :products, :class_name => 'DistributionPluginOrderedProduct', :foreign_key => 'order_id', :dependent => :destroy,
    :order => 'id asc', :include => :product

  has_many :session_products, :through => :products, :source => :product
  has_many :distributed_products, :through => :session_products, :source => :from_products
  has_many :supplier_products, :through => :distributed_products, :source => :from_products

  has_many :from_products, :through => :products
  has_many :to_products, :through => :products
  
  has_one :supplier_delivery, :class_name => 'DistributionPluginDeliveryMethod'
  has_one :consumer_delivery, :class_name => 'DistributionPluginDeliveryMethod'

  named_scope :by_consumer, lambda { |consumer| { :conditions => {:consumer_id => consumer.id} } }

  extend CodeNumbering::ClassMethods
  code_numbering :code, :scope => Proc.new { self.session.orders }

  validates_inclusion_of :status, :in => ['draft', 'planned', 'confirmed']
  validates_presence_of :session
  validates_presence_of :consumer
  validates_presence_of :supplier_delivery
  validates_presence_of :consumer_delivery, :if => :is_delivery?

  named_scope :draft, :conditions => {:status => 'draft'}
  named_scope :planned, :conditions => {:status => 'planned'}
  named_scope :confirmed, :conditions => {:status => 'confirmed'}
  def draft?
    status == 'draft'
  end
  def planned?
    status == 'planned'
  end
  def confirmed?
    status == 'confirmed'
  end
  def open?
    !confirmed? && session.open?
  end
  def forgotten?
    !confirmed? && !session.open?
  end

  def supplier_delivery
    self['supplier_delivery'] || session.delivery_methods.first
  end
  def is_delivery?
    supplier_delivery and supplier_delivery.deliver?
  end

  def total_quantity_asked
    products.sum(:quantity_asked)
  end
  def total_price_asked
    products.sum(:price_asked)
  end
  def parcel_quantity_total
    #TODO
    total_quantity_asked
  end
  def parcel_price_total
    #TODO
    total_price_asked
  end

  def code
    _("%{sessioncode}.%{ordercode}") % {
      :sessioncode => session.code, :ordercode => self['code']
    }
  end

  protected 

  before_validation :default_values
  def default_values
    self.status ||= 'draft'
    self.supplier_delivery
  end

end

class DistributionPluginOrder < ActiveRecord::Base
  belongs_to :session, :class_name => 'DistributionPluginSession'
  belongs_to :consumer, :class_name => 'DistributionPluginNode'

  has_many :products, :class_name => 'DistributionPluginOrderedProduct', :foreign_key => 'order_id', :dependent => :destroy
  has_many :suppliers, :through => :products #FIXME: not working
  has_many :supplied_products, :through => :products, :source => :product
  
  has_one :supplier_delivery, :class_name => 'DistributionPluginDeliveryMethod'
  has_one :consumer_delivery, :class_name => 'DistributionPluginDeliveryMethod'

  named_scope :draft, :conditions => {:status => 'draft'}
  named_scope :planned, :conditions => {:status => 'planned'}
  named_scope :confirmed, :conditions => {:status => 'confirmed'}

  validates_inclusion_of :status, :in => ['draft', 'planned', 'confirmed']
  validates_presence_of :session
  validate :open_session?, :if => :session

  validates_presence_of :consumer

  validates_presence_of :supplier_delivery
  validates_presence_of :consumer_delivery, :if => :is_delivery?

  def supplier_delivery
    self['supplier_delivery'] ||= session.delivery_methods.first
  end

  def is_delivery?
    supplier_delivery and supplier_delivery.delivery_type == 'delivery'
  end

  def open_session?
    if !session.open?
      errors.add_to_base('associated session is closed')
    end
  end

  def confirmed?
    status == 'confirmed'
  end

  protected 

  before_validation :default_values
  def default_values
    self.status ||= 'draft'
    self.supplier_delivery
  end

end

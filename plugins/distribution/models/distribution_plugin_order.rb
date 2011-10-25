class DistributionPluginOrder < ActiveRecord::Base
  belongs_to :session, :class_name => 'DistributionPluginSession'
  belongs_to :consumer, :class_name => 'DistributionPluginNode'

  has_many :suppliers, :through => :products, :uniq => true
  has_many :products, :class_name => 'DistributionPluginOrderedProduct', :foreign_key => 'order_id', :dependent => :destroy, :order => 'id asc'

  has_many :used_products, :through => :products, :source => :product

  has_many :from_products, :through => :products
  has_many :to_products, :through => :products
  
  has_one :supplier_delivery, :class_name => 'DistributionPluginDeliveryMethod'
  has_one :consumer_delivery, :class_name => 'DistributionPluginDeliveryMethod'

  named_scope :by_consumer, lambda { |consumer| { :conditions => {:consumer_id => consumer.id} } }

  validates_inclusion_of :status, :in => ['draft', 'planned', 'confirmed']
  validates_presence_of :session
  validate :open_session?, :if => :session

  validates_presence_of :consumer

  validates_presence_of :supplier_delivery
  validates_presence_of :consumer_delivery, :if => :is_delivery?

  named_scope :draft, :conditions => {:status => 'draft'}
  named_scope :planned, :conditions => {:status => 'planned'}
  named_scope :confirmed, :conditions => {:status => 'confirmed'}
  def draft?
    status == 'draft'
  end
  def planned
    status == 'planned'
  end
  def confimerd
    status == 'confirmed'
  end

  def supplier_delivery
    self['supplier_delivery'] || session.delivery_methods.first
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

  def total_asked
    products.sum(:price_asked)
  end

  protected 

  before_validation :default_values
  def default_values
    self.status ||= 'draft'
    self.supplier_delivery
  end

end

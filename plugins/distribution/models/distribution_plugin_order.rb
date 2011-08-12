class DistributionPluginOrder < ActiveRecord::Base
  belongs_to :session, :class_name => 'DistributionPluginSession'
  belongs_to :consumer, :class_name => 'DistributionPluginNode'
  has_one :supplier, :through => :session, :source => :node
  def supplier
    self.session.node
  end
  
  has_one :supplier_delivery, :class_name => 'DistributionPluginDeliveryMethod'
  has_one :consumer_delivery, :class_name => 'DistributionPluginDeliveryMethod'
  has_many :ordered_products, :class_name => 'DistributionPluginOrderedProduct', :foreign_key => 'order_id'

  named_scope :draft, :conditions => {:status => 'draft'}
  named_scope :planned, :conditions => {:status => 'planned'}
  named_scope :confirmed, :conditions => {:status => 'confirmed'}

  validates_presence_of :session
  validates_presence_of :consumer
  validates_inclusion_of :status, :in => ['draft', 'planned', 'confirmed']
  validate :open_session?, :if => :session
  validate :delivery_method?
  before_validation :default_values

  def default_values
    self.status ||= 'draft'
  end


  def delivery_method?
    # TODO: create an unit test for this
    # TODO: validate supplier's and consumer's delivery method being filled.
    #validates_presence_of :supplier_delivery
    #validates_presence_of :consumer_delivery, :if => :is_delivery?
    if status == 'confirmed' and supplier_delivery.nil?
      errors.add_to_base('cannot confirm order without delivery method')
    end
  end

  def is_delivery?
    supplier_delivery and supplier_delivery.delivery_type == 'delivery'
  end

  def open_session?
    if !session.open?
      errors.add_to_base('associated session is closed')
    end
  end

end

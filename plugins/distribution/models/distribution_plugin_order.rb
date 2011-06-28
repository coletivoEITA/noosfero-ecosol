class DistributionPluginOrder < ActiveRecord::Base
  has_one :supplier, :through => :distribution_order_sessions, :source => :node_id
  belongs_to :consumer, :class_name => 'DistributionPluginNode'
  has_one :supplier_delivery, :class_name => 'DistributionPluginDeliveryMethod'
  has_one :consumer_delivery, :class_name => 'DistributionPluginDeliveryMethod'
  belongs_to :order_session, :class_name => 'DistributionPluginOrderSession'
  has_many :ordered_products, :class_name => 'DistributionPluginOrderedProduct'
  before_validation :default_values

  def default_values
    self.status ||= 'draft'
  end

  validates_presence_of :order_session
  validates_inclusion_of :status, :in => ['draft', 'planned', 'confirmed']
  validate :open_session?
  validate :delivery_method?

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
    if !order_session.open?
      errors.add_to_base('associated session is closed')
    end
  end

  def close
  end
end

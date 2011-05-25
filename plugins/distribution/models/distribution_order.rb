class DistributionOrder < ActiveRecord::Base
  has_one :supplier, :through => :distribution_order_sessions, :source => :node_id
  belongs_to :consumer, :class_name => 'DistributionNode'
  has_one :supplier_delivery, :class_name => 'DistributionDeliveryMethod'
  has_one :consumer_delivery, :class_name => 'DistributionDeliveryMethod'
  belongs_to :order_session, :class_name => 'DistributionOrderSession'
  has_many :ordered_products, :class_name => 'DistributionOrderedProducts'

  validates_presence_of :supplier_delivery
  #validates_presence_of :consumer_delivery, :if => :is_delivery?
  validate :open_session?

  def is_delivery?
    supplier_delivery and supplier_delivery.delivery_type == 'delivery'
  end

  def open_session?
    if !order_session.open?
      errors.add_to_base('associated session is closed')
    end
  end
end

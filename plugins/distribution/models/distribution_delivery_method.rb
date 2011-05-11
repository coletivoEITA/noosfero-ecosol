class DistributionDeliveryMethod < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionNode'
  has_many :orders, :class_name => 'DistributionOrder'

  validates_presence_of :node
  validates_inclusion_of :delivery_type, :in => ['pickup', 'delivery']
  validates_presence_of :address_line1, :if => :is_pickup?
  validates_presence_of :state, :if => :is_pickup?
  validates_presence_of :country, :if => :is_pickup?

  def is_pickup?
    delivery_type == 'pickup'
  end
end

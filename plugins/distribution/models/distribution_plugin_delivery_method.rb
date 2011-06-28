class DistributionPluginDeliveryMethod < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionPluginNode'
  has_many :orders, :class_name => 'DistributionPluginOrder'
  belongs_to :delivery_option, :class_name => 'DistributionPluginDeliveryOption'

  validates_presence_of :node
  validates_inclusion_of :delivery_type, :in => ['pickup', 'delivery']
  validates_presence_of :address_line1, :if => :is_pickup?
  validates_presence_of :state, :if => :is_pickup?
  validates_presence_of :country, :if => :is_pickup?

  def is_pickup?
    delivery_type == 'pickup'
  end
end

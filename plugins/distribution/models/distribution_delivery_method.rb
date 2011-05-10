class DistributionDeliveryMethod < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionNode'
  has_many :orders, :class_name => 'DistributionOrder'

  validates_presence_of :node
  validates_inclusion_of :type, :in => ['pickup', 'delivery']

  validate :validates_address_on_type
  def validates_address_on_type
    if type == 'pickup'
      validates_presence_of :address_line1
      validates_presence_of :state
      validates_presence_of :country
    end
  end
end

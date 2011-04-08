class DistributionDeliveryMethod < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionNode'
  has_many :orders, :class_name => 'DistributionOrder'
end

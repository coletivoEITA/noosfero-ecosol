class DistributionOrder < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionNode'
  belongs_to :delivery_method, :class_name => 'DistributionDeliveryMethod'
  belongs_to :order_session, :class_name => 'DistributionOrderSession'
  has_many :ordered_products, :class_name => 'DistributionOrderedProducts'

end

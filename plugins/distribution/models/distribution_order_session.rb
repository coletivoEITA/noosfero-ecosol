class DistributionOrderSession < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionNode'
  has_many :orders, :class_name => 'DistributionOrder'
  has_many :products, :class_name => 'DistributionProduct'
end

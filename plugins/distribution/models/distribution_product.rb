class DistributionProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :node, :class_name => 'DistributionNode'
end

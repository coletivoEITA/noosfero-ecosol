class DistributionProduct < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionNode'
  belongs_to :product
  has_many   :sources, :class_name => 'DistributionSourceProduct', :foreign_key => 'to_product_id'
  has_many   :used_by, :class_name => 'DistributionSourceProduct', :foreign_key => 'from_product_id'
end

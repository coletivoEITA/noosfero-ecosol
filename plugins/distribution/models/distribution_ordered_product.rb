class DistributionOrderedProduct < ActiveRecord::Base
  belongs_to :order, :class_name => 'DistributionOrder'
  belongs_to :session_product, :class_name => 'DistributionSessionProduct'

end

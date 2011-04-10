class DistributionSourceProduct < ActiveRecord::Base
  belongs_to :from_product, :class_name => 'DistributionProduct', :foreign_key => 'from_product_id'
  belongs_to :to_product, :class_name => 'DistributionProduct', :foreign_key => 'to_product_id'
end

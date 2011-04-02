class DistributionProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :distribution_node
end

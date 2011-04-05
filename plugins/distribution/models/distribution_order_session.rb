class DistributionOrderSession < ActiveRecord::Base
  belongs_to :distribution_node
  has_many :distribution_orders
  has_many :distribution_delivery_methods
end

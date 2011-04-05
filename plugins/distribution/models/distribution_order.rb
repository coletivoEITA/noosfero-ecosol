class DistributionOrder < ActiveRecord::Base
  belongs_to :distribution_nodes
  belongs_to :distribution_delivery_methods
  belongs_to :distribution_order_sessions
  $has_many :distribution_ordered_products
end

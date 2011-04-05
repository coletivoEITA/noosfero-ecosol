class DistributionDeliveryMethod < ActiveRecord::Base
	belongs_to :distribution_node
	has_many :distribution_order
end

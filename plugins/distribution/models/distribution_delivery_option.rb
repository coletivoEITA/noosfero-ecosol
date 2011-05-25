class DistributionDeliveryOption < ActiveRecord::Base
  belongs_to :delivery_method, :class_name => 'DistributionDeliveryMethod'
  belongs_to :order_session, :class_name => 'DistributionOrderSession'
end

class DistributionPluginDeliveryOption < ActiveRecord::Base
  belongs_to :delivery_method, :class_name => 'DistributionPluginDeliveryMethod'
  belongs_to :order_session, :class_name => 'DistributionPluginOrderSession'
end

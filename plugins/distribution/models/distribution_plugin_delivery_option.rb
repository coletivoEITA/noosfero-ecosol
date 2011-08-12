class DistributionPluginDeliveryOption < ActiveRecord::Base
  belongs_to :delivery_method, :class_name => 'DistributionPluginDeliveryMethod'
  belongs_to :session, :class_name => 'DistributionPluginSession'

  validates_presence_of :session
  validates_presence_of :delivery_method
end

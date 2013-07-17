class DistributionPlugin::DeliveryOption < Noosfero::Plugin::ActiveRecord

  belongs_to :delivery_method, :class_name => 'DistributionPlugin::DeliveryMethod'
  belongs_to :session, :class_name => 'DistributionPlugin::Session'

  validates_presence_of :session
  validates_presence_of :delivery_method

end

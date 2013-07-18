class DistributionPlugin::SessionOrder < Noosfero::Plugin::ActiveRecord

  belongs_to :session, :class_name => 'DistributionPlugin::Session'
  belongs_to :order, :class_name => 'OrdersPlugin::Orders'

  validates_presence_of :session
  validates_presence_of :order

end

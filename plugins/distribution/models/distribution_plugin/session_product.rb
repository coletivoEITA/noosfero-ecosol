class DistributionPlugin::SessionProduct < Noosfero::Plugin::ActiveRecord

  belongs_to :session, :class_name => 'DistributionPlugin::Session'
  belongs_to :product, :class_name => 'DistributionPlugin::OfferedProduct'

  validates_presence_of :session
  validates_presence_of :product

end

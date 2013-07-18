class DeliveryPlugin::DeliveryOption < Noosfero::Plugin::ActiveRecord

  def self.table_name
    'delivery_plugin_options'
  end

  belongs_to :delivery_method, :class_name => 'DeliveryPlugin::DeliveryMethod'
  belongs_to :session, :class_name => 'DistributionPlugin::Session'

  validates_presence_of :session
  validates_presence_of :delivery_method

end

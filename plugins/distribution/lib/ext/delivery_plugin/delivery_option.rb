require_dependency 'delivery_plugin/delivery_option'

class DeliveryPlugin::DeliveryOption

  belongs_to :session, :class_name => 'DistributionPlugin::Session',
    :foreign_key => :owner_id, :conditions => ["delivery_plugin_options.owner_type = 'DistributionPlugin::Session'"]

end

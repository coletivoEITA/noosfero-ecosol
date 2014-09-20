class DeliveryPlugin::Option < Noosfero::Plugin::ActiveRecord

  # FIXME: some unknown code is overwriting this to orders_cycle_plugin_cycles
  set_table_name 'delivery_plugin_options'

  belongs_to :delivery_method, :class_name => 'DeliveryPlugin::Method'
  belongs_to :owner, :polymorphic => true

  validates_presence_of :delivery_method
  validates_presence_of :owner

end

# FIXME remove Delivery when plugins scope problem is solved
class DeliveryPlugin::DeliveryOption < Noosfero::Plugin::ActiveRecord

  def self.table_name
    'delivery_plugin_options'
  end

  belongs_to :delivery_method, :class_name => 'DeliveryPlugin::DeliveryMethod'
  belongs_to :owner, :polymorphic => true

  validates_presence_of :delivery_method
  validates_presence_of :owner

end

class DeliveryPlugin::Option < Noosfero::Plugin::ActiveRecord

  belongs_to :delivery_method, :class_name => 'DeliveryPlugin::Method'
  belongs_to :owner, :polymorphic => true

  validates_presence_of :delivery_method
  validates_presence_of :owner

end

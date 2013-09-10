class OrdersCyclePlugin::CycleProduct < Noosfero::Plugin::ActiveRecord

  belongs_to :cycle, :class_name => 'OrdersCyclePlugin::Cycle'
  belongs_to :product, :class_name => 'OrdersCyclePlugin::OfferedProduct'

  validates_presence_of :cycle
  validates_presence_of :product

end

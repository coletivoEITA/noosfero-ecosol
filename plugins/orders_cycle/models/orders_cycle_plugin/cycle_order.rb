class OrdersCyclePlugin::CycleOrder < Noosfero::Plugin::ActiveRecord

  belongs_to :cycle, :class_name => 'OrdersCyclePlugin::Cycle'
  belongs_to :order, :class_name => 'OrdersPlugin::Order', :dependent => :destroy

  validates_presence_of :cycle
  validates_presence_of :order

end

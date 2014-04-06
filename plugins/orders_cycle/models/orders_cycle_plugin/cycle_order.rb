class OrdersCyclePlugin::CycleOrder < Noosfero::Plugin::ActiveRecord

  belongs_to :cycle, :class_name => 'OrdersCyclePlugin::Cycle'
  belongs_to :sale, :class_name => 'OrdersPlugin::Sale', :dependent => :destroy
  belongs_to :purchase, :class_name => 'OrdersPlugin::Purchase', :foreign_key => :order_id, :dependent => :destroy

  validates_presence_of :cycle
  validates_presence_of :order

end

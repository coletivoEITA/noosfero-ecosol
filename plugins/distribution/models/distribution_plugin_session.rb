class DistributionPluginPluginSession < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionPluginNode'
  has_many :orders, :class_name => 'DistributionPluginOrder'
  has_many :products, :class_name => 'DistributionPluginSessionProduct', :foreign_key => :order_session_id
  has_many :delivery_methods, :class_name => 'DistributionPluginDeliveryOption', :foreign_key => :order_session_id
  #has_many :delivery_methods, :through => :distribution_delivery_options

  def open?
    now = DateTime.now
    now >= self.start and now <= self.finish
  end
end

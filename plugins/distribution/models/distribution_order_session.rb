class DistributionOrderSession < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionNode'
  has_many :orders, :class_name => 'DistributionOrder'
  has_many :products, :class_name => 'DistributionProduct'
  has_many :delivery_methods, :class_name => 'DistributionDeliveryOption', :foreign_key => :order_session_id
  #has_many :delivery_methods, :through => :distribution_delivery_options

  def open?
    puts self.start
    puts self.finish
    now = DateTime.now
    puts now
    now >= self.start and now <= self.finish
  end
end

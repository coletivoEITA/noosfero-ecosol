class DistributionPluginSession < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionPluginNode'
  has_many :orders, :class_name => 'DistributionPluginOrder', :foreign_key => :session_id, :dependent => :destroy
  has_many :products, :class_name => 'DistributionPluginSessionProduct', :foreign_key => :session_id, :dependent => :destroy
  has_many :delivery_options, :class_name => 'DistributionPluginDeliveryOption', :foreign_key => :session_id, :dependent => :destroy
  has_many :delivery_methods, :through => :delivery_options, :source => :delivery_method
  
  validates_presence_of :node

  after_create :add_distributed_products

  extend SplitDatetime::SplitMethods
  split_datetime :start
  split_datetime :finish
  split_datetime :delivery_start
  split_datetime :delivery_finish

  def open?
    now = DateTime.now
    now >= self.start and now <= self.finish
  end

  def add_distributed_products
    self.products = node.products.map do |p|
       DistributionPluginSessionProduct.create!(:product => p, :price => p.price)
    end
  end
end

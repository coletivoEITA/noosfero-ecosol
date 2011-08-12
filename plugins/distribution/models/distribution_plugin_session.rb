class DistributionPluginSession < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionPluginNode', :foreign_key => :node_id
  has_many :orders, :class_name => 'DistributionPluginOrder', :foreign_key => :session_id, :dependent => :destroy
  has_many :products, :class_name => 'DistributionPluginSessionProduct', :foreign_key => :session_id, :dependent => :destroy

  has_many :delivery_options, :class_name => 'DistributionPluginDeliveryOption', :foreign_key => :session_id, :dependent => :destroy
  has_many :delivery_methods, :through => :delivery_options, :source => :delivery_method

  has_many :ordered_suppliers, :through => :orders, :source => :supplier
  has_many :ordered_products, :through => :orders

  STATUS_SEQUENCE = [
    'new', 'edition', 'call', 'open', 'parcels', 'redistribution', 'delivery', 'close', 'closed'
  ]
  
  validates_presence_of :node
  validates_inclusion_of :status, :in => STATUS_SEQUENCE
  before_validation :default_values

  def default_values
    self.status ||= 'new'
  end

  before_update :change_status
  def change_status
    self.status = 'edition' if self.status == 'new'
  end

  after_create :add_distributed_products

  extend SplitDatetime::SplitMethods
  split_datetime :start
  split_datetime :finish
  split_datetime :delivery_start
  split_datetime :delivery_finish
  
  def passed_by?(status)
    STATUS_SEQUENCE.index(self.status) > STATUS_SEQUENCE.index(status)
  end

  def open?
    now = DateTime.now
    status == 'open' && now >= self.start && now <= self.finish
  end

  def in_delivery?
    now = DateTime.now
    now >= self.delivery_start and now <= self.delivery_finish
  end

  def add_distributed_products
    self.products = node.products.map do |p|
       DistributionPluginSessionProduct.create!(:product => p, :price => p.price, :quantity_available => p.stored)
    end
  end

  def ordered_products_by_suppliers
   hash = {}
   self.ordered_products.each do |p|
     hash[p.supplier] ||= []
     hash[p.supplier] << p
   end
   hash
  end
end

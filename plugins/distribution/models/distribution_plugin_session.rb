class DistributionPluginSession < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionPluginNode', :foreign_key => :node_id

  has_many :delivery_options, :class_name => 'DistributionPluginDeliveryOption', :foreign_key => :session_id, :dependent => :destroy
  has_many :delivery_methods, :through => :delivery_options, :source => :delivery_method

  has_many :orders, :class_name => 'DistributionPluginOrder', :foreign_key => :session_id, :dependent => :destroy, :order => 'id asc'
  has_many :products, :class_name => 'DistributionPluginProduct', :foreign_key => :session_id, :dependent => :destroy

  has_many :from_products, :through => :products
  has_many :from_nodes, :through => :products
  has_many :to_nodes, :through => :products

  has_many :ordered_products, :through => :orders, :source => :products
  has_many :ordered_suppliers, :through => :orders, :source => :suppliers
  has_many :ordered_supplied_products, :through => :orders, :source => :used_products, :uniq => true

  STATUS_SEQUENCE = [
    'new', 'edition', 'call', 'orders', 'parcels', 'redistribution', 'delivery', 'close', 'closed'
  ]
  
  validates_presence_of :node
  validates_presence_of :name
  validates_presence_of :start
  validates_inclusion_of :status, :in => STATUS_SEQUENCE
  validates_presence_of :delivery_methods
  validates_numericality_of :margin_percentage, :allow_nil => true
  validates_numericality_of :margin_fixed, :allow_nil => true
  before_validation :default_values

  extend SplitDatetime::ClassMethods
  split_datetime :start
  split_datetime :finish
  split_datetime :delivery_start
  split_datetime :delivery_finish
  
  def passed_by?(status)
    STATUS_SEQUENCE.index(self.status) > STATUS_SEQUENCE.index(status)
  end

  named_scope :open, lambda {
    {:conditions => ["status = 'orders' AND ( (start <= :date AND finish IS NULL) OR (start <= :date AND finish >= :date) )",
      {:date => DateTime.now}]}
  }

  def open?
    now = DateTime.now
    status == 'orders' && ( (self.start <= now && self.finish.nil?) || (self.start <= now && self.finish >= now) )
  end

  def in_delivery?
    now = DateTime.now
    now >= self.delivery_start and now <= self.delivery_finish
  end

  def ordered_products_by_suppliers
    self.ordered_supplied_products.group_by { |p| p.supplier }
  end

  protected

  def default_values
    self.status ||= 'new'
  end

  before_update :change_status
  def change_status
    self.status = 'edition' if self.status == 'new'
  end

  after_create :add_distributed_products
  def add_distributed_products
    self.products += node.products.distributed.map do |dp|
       p = dp.clone
       p.session = self
       p.save!
       DistributionPluginSourceProduct.create :from_product => dp, :to_product => p
       p
    end
  end

end

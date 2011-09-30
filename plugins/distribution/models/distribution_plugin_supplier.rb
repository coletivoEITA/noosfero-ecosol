class DistributionPluginSupplier < ActiveRecord::Base
  belongs_to :node,  :class_name => 'DistributionPluginNode'
  belongs_to :consumer,  :class_name => 'DistributionPluginNode'

  has_many :products, :through => :node
  has_many :consumer_products, :through => :consumer, :source => :products

  validates_presence_of :node
  validates_presence_of :consumer

  has_one :profile, :through => :node
  def profile
    node.profile
  end

  extend DefaultItem::ClassMethods
  default_item :name, :delegate_to => :profile
  default_item :description, :delegate_to => :profile
end

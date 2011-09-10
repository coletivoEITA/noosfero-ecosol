class DistributionPluginNode < ActiveRecord::Base
  belongs_to :profile

  has_many :delivery_methods, :class_name => 'DistributionPluginDeliveryMethod', :foreign_key => 'node_id', :dependent => :destroy
  has_many :sessions, :class_name => 'DistributionPluginSession', :foreign_key => 'node_id', :dependent => :destroy
  has_many :orders, :through => :sessions, :source => :orders, :dependent => :destroy
  has_many :parcels, :class_name => 'DistributionPluginOrder', :foreign_key => 'consumer_id', :dependent => :destroy

  has_many :products, :class_name => 'DistributionPluginProduct', :foreign_key => 'node_id', :dependent => :destroy
  has_many :order_products, :through => :orders, :source => :products
  has_many :parcel_products, :through => :parcels, :source => :products

  has_many :from_products, :through => :products
  has_many :to_products, :through => :products
  has_many :from_suppliers, :through => :products
  has_many :to_suppliers, :through => :products

  validates_presence_of   :profile
  validates_inclusion_of  :role, :in => ['supplier', 'collective', 'consumer']
  validates_numericality_of :margin_percentage, :allow_nil => true
  validates_numericality_of :margin_fixed, :allow_nil => true

  def dummy?
    !profile.visible
  end

  module Roles
    def self.consumer(env_id)
      find_role('consumer', env_id)
    end

    private
    def self.find_role(name, env_id)
      ::Role.find_by_key_and_environment_id("distribution_node_#{name}", env_id)
    end
  end

  acts_as_accessor
  acts_as_accessible
  named_scope :consumers_of, lambda { |supplier| { :select => 'DISTINCT distribution_plugin_nodes.*', :joins => 'LEFT JOIN role_assignments ON role_assignments.resource_id = distribution_plugin_nodes.id', :conditions => ['role_assignments.accessor_type = ? AND role_assignments.accessor_id = ?', supplier.class.base_class.name, supplier.id ] } }
  named_scope :suppliers_of, lambda { |consumer| { :select => 'DISTINCT distribution_plugin_nodes.*', :joins => 'LEFT JOIN role_assignments ON role_assignments.accessor_id = distribution_plugin_nodes.id', :conditions => ['role_assignments.resource_type = ? AND role_assignments.resource_id = ?', consumer.class.base_class.name, consumer.id ] } }
  def consumers
    DistributionPluginNode.consumers_of(self)
  end
  def suppliers
    DistributionPluginNode.suppliers_of(self)
  end

  before_create :check_roles
  def check_roles
    Role.create!(
      :key => 'distribution_node_consumer',
      :name => N_('Consumer'),
      :environment => profile.environment,
      :permissions => [
        'order_product',
      ]
    ) if profile and !DistributionPluginNode::Roles.consumer(profile.environment)
  end

  def self.find_or_create(profile)
    role = profile.person? ? 'consumer' : (profile.community? ? 'collective' : 'supplier')
    find_by_profile_id(profile.id) || create!(:profile => profile, :role => role)
  end

  def myprofile_controller
    'distribution_plugin_' + role
  end

  def add_consumer(consumer)
    consumer.affiliate self, DistributionPluginNode::Roles.consumer(self.profile.environment)
  end
  def add_supplier(supplier)
    supplier.add_consumer self
  end
  def remove_consumer(consumer)
    consumer.disaffiliate self, DistributionPluginNode::Roles.consumer(self.profile.environment)
    #consumer.products.update_all {:deleted => true}, {
  end
  def remove_supplier(supplier)
    supplier.remove_consumer self
  end

  def add_node_products(node)
    raise "Can't add product from a non supplier node" unless suppliers.include?(node)
    node.products.map do |np|
       p = np.clone
       p.node = self
       p.supplier = node
       p.margin_percentage = nil
       p.margin_fixed = nil
       p.apply_distribution
       p.save!
       DistributionPluginSourceProduct.create :from_product => np, :to_product => p
       p
    end
  end 

  protected
  after_create :add_own_products
  def add_own_products
    if profile.respond_to? :products
      profile.products.map do |p|
        DistributionPluginProduct.create!(:node => self, :supplier => self, :product => p, :name => p.name, :description => p.description, :price => p.price, :unit => p.unit)
      end
    end
  end

  #for access_control
  def blocks_to_expire_cache
    []
  end
  def cache_keys(params = {})
    []
  end
end

class DistributionPluginNode < ActiveRecord::Base
  belongs_to :profile

  has_many :delivery_methods, :class_name => 'DistributionPluginDeliveryMethod', :foreign_key => 'node_id', :dependent => :destroy, :order => 'id asc'
  has_many :sessions, :class_name => 'DistributionPluginSession', :foreign_key => 'node_id', :dependent => :destroy, :order => 'id asc'
  has_many :orders, :through => :sessions, :source => :orders, :dependent => :destroy, :order => 'id asc'
  has_many :parcels, :class_name => 'DistributionPluginOrder', :foreign_key => 'consumer_id', :dependent => :destroy, :order => 'id asc'

  has_many :suppliers, :class_name => 'DistributionPluginSupplier', :foreign_key => 'consumer_id', :order => 'id asc', :dependent => :destroy
  has_many :consumers, :class_name => 'DistributionPluginSupplier', :foreign_key => 'node_id', :order => 'id asc'
  has_many :suppliers_nodes, :through => :suppliers, :source => :node, :order => 'id asc'
  has_many :consumers_nodes, :through => :consumers, :source => :consumer, :order => 'id asc'

  has_many :products, :class_name => 'DistributionPluginProduct', :foreign_key => 'node_id', :dependent => :destroy, :order => 'distribution_plugin_products.id asc'
  has_many :order_products, :through => :orders, :source => :products, :order => 'id asc'
  has_many :parcel_products, :through => :parcels, :source => :products, :order => 'id asc'
  has_many :supplier_products, :through => :suppliers, :source => :products, :order => 'id asc'
  has_many :consumer_products, :through => :consumers, :source => :consumer_products, :order => 'id asc'

  has_many :from_products, :through => :products
  has_many :to_products, :through => :products
  has_many :from_nodes, :through => :products
  has_many :to_nodes, :through => :products

  validates_presence_of :profile
  validates_associated :profile
  validates_inclusion_of :role, :in => ['supplier', 'collective', 'consumer']
  validates_numericality_of :margin_percentage, :allow_nil => true
  validates_numericality_of :margin_fixed, :allow_nil => true

  def self.find_or_create(profile)
    role = profile.person? ? 'consumer' : (profile.community? ? 'collective' : 'supplier')
    find_by_profile_id(profile.id) || create!(:profile => profile, :role => role)
  end

  def name
    profile.name
  end
  def abbreviation_or_name
    self['name_abbreviation'] || name
  end

  def consumer?
    role == 'consumer'
  end
  def supplier?
    role == 'supplier'
  end
  def collective?
    role == 'collective'
  end
  def dummy?
    !profile.visible
  end

  def default_products_margins
    products.unarchived.distributed.each do |product|
      product.default_margin_percentage = true
      product.default_margin_fixed = true
      product.save!
    end
    sessions.not_open.each do |session|
      session.products.each do |product|
        product.margin_percentage = margin_percentage
        product.margin_fixed = margin_fixed
        product.save!
      end
    end
  end

  def not_distributed_products(supplier)
    raise "#{supplier.name} is not a supplier of #{self.profile.name}" unless has_supplier?(supplier)
    supplier.node.products.unarchived.own.distributed - self.from_products.unarchived.distributed.by_node(supplier.node)
  end

  def self_supplier
    suppliers.from_node(self).first || DistributionPluginSupplier.create!(:node => self, :consumer => self)
  end
  def has_supplier?(supplier)
    suppliers.include? supplier
  end
  def has_consumer?(consumer)
    consumers.include? consumer
  end
  def add_supplier(supplier)
    supplier.add_consumer self
  end
  def remove_supplier(supplier)
    supplier.remove_consumer self
  end
  def add_consumer(consumer)
    consumer.affiliate self, DistributionPluginNode::Roles.consumer(self.profile.environment)
    consumers.create! :consumer => consumer unless has_consumer?(consumer)

    #without asking the user?
    consumer.add_supplier_products self unless consumer.consumer?
  end
  def remove_consumer(consumer)
    consumer.disaffiliate self, DistributionPluginNode::Roles.consumer(self.profile.environment)
    consumers.find_by_consumer_id(consumer.id).destroy!

    consumer.products.distributed.from_supplier(self).update_all ['archived = true']
  end

  def add_supplier_products(supplier)
    raise "Can't add product from a non supplier node" unless has_supplier?(supplier)

    already_supplied = self.products.unarchived.distributed.from_supplier(supplier).all
    supplier.products.unarchived.map do |np|
      p = already_supplied.find{ |f| f.supplier_product == np }
      unless p
        p = DistributionPluginDistributedProduct.new :node => self
        p.distribute_from np
        p.save!
      end
      p
    end
  end 

  alias_method :destroy!, :destroy
  def destroy
    #TODO soft delete products
    destroy!
  end

  protected

  after_create :add_self_supplier
  def add_self_supplier
    self_supplier
  end

  after_create :add_own_members
  def add_own_members
    profile.members.map do |member| 
      consumer = DistributionPluginNode.find_or_create member
      add_consumer consumer
      consumer
    end
  end

  after_create :add_own_products
  def add_own_products
    return unless profile.respond_to? :products

    already_supplied = self.products.unarchived.distributed.from_supplier(self).all
    profile.products.map do |p|
      already_supplied.find{ |f| f.product == p } ||
        DistributionPluginDistributedProduct.create!(:node => self, :supplier => self_supplier, :product => p, :name => p.name, :description => p.description, :price => p.price, :unit => p.unit)
    end
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

  before_create :check_roles
  def check_roles
    Role.create!(
      :key => 'distribution_node_consumer',
      :name => N_('Consumer'),
      :environment => profile.environment,
      :permissions => [
        'order_product',
      ]
    ) if profile and not DistributionPluginNode::Roles.consumer(profile.environment)
  end


  #for access_control
  def blocks_to_expire_cache
    []
  end
  def cache_keys(params = {})
    []
  end

end

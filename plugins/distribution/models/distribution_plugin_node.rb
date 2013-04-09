class DistributionPluginNode < ActiveRecord::Base

  belongs_to :profile

  has_many :delivery_methods, :class_name => 'DistributionPluginDeliveryMethod', :foreign_key => 'node_id', :dependent => :destroy, :order => 'id ASC'
  has_many :delivery_options, :through => :delivery_methods

  has_many :sessions, :class_name => 'DistributionPluginSession', :foreign_key => 'node_id', :dependent => :destroy, :order => 'created_at DESC',
    :conditions => ["distribution_plugin_sessions.status <> 'new'"]
  has_many :orders, :through => :sessions, :source => :orders, :dependent => :destroy, :order => 'id ASC'
  has_many :parcels, :class_name => 'DistributionPluginOrder', :foreign_key => 'consumer_id', :dependent => :destroy, :order => 'id ASC'

  has_many :suppliers, :class_name => 'DistributionPluginSupplier', :foreign_key => 'consumer_id', :order => 'name ASC', :dependent => :destroy
  has_many :consumers, :class_name => 'DistributionPluginSupplier', :foreign_key => 'node_id', :order => 'name ASC'
  has_many :suppliers_nodes, :through => :suppliers, :source => :node, :order => 'distribution_plugin_nodes.id ASC'
  has_many :consumers_nodes, :through => :consumers, :source => :consumer, :order => 'distribution_plugin_nodes.id ASC'

  has_many :products, :class_name => 'DistributionPluginProduct', :foreign_key => 'node_id', :dependent => :destroy, :order => 'distribution_plugin_products.name ASC'
  has_many :order_products, :through => :orders, :source => :products, :order => 'name ASC'
  has_many :parcel_products, :through => :parcels, :source => :products, :order => 'id ASC'
  has_many :supplier_products, :through => :suppliers, :source => :products, :order => 'name ASC'
  has_many :consumer_products, :through => :consumers, :source => :consumer_products, :order => 'id ASC'

  has_many :from_products, :through => :products
  has_many :to_products, :through => :products
  has_many :from_nodes, :through => :products
  has_many :to_nodes, :through => :products

  has_many :sessions_custom_order, :class_name => 'DistributionPluginSession', :foreign_key => 'node_id', :dependent => :destroy,
    :conditions => ["distribution_plugin_sessions.status <> 'new'"]

  validates_presence_of :profile
  validates_inclusion_of :role, :in => ['supplier', 'collective', 'consumer']
  validates_numericality_of :margin_percentage, :allow_nil => true
  validates_numericality_of :margin_fixed, :allow_nil => true

  extend DistributionPlugin::DistributionCurrencyHelper::ClassMethods
  has_number_with_locale :margin_percentage
  has_number_with_locale :margin_fixed

  acts_as_having_image
  belongs_to :image, :class_name => 'DistributionPluginHeaderImage'

  after_create :add_self_supplier
  after_create :add_own_members
  after_create :add_own_products
  after_update :save_image
  before_create :check_roles

  def self.find_or_create(profile)
    find_by_profile_id(profile.id) || create!(:profile => profile, :role => 'consumer')
  end

  def name
    profile.name
  end
  def abbreviation_or_name
    self['name_abbreviation'] || name
  end

  def enabled?
    !consumer?
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
  alias_method :dummy, :dummy?
  def dummy=(value)
    profile.update_attributes! :visible => !value
  end

  def closed_sessions_date_range
    list = sessions.not_open.all :order => 'start ASC'
    return DateTime.now..DateTime.now if list.blank?
    list.first.start.to_date..list.last.finish.to_date
  end

  def default_products_margins
    products.unarchived.distributed.each do |product|
      product.default_margin_percentage = true
      product.default_margin_fixed = true
      product.save!
    end
    sessions.open.each do |session|
      session.products.each do |product|
        product.margin_percentage = margin_percentage
        product.margin_fixed = margin_fixed
        product.save!
      end
    end
  end

  alias_method :orig_suppliers, :suppliers
  def suppliers
    self_supplier # guarantee that the self_supplier is created
    orig_suppliers
  end
  def self_supplier
    return self.orig_suppliers.build(:node => self) if new_record?
    orig_suppliers.from_node(self).first || self.orig_suppliers.create!(:node => self)
  end

  def has_supplier?(supplier)
    suppliers.include? supplier
  end
  def has_consumer?(consumer)
    consumers.include? consumer
  end
  def has_supplier_node?(supplier)
    suppliers_nodes.include? supplier
  end
  def has_consumer_node?(consumer)
    consumers_nodes.include? consumer
  end
  def add_supplier(supplier)
    supplier.add_consumer self
  end
  def remove_supplier(supplier)
    supplier.remove_consumer self
  end
  def add_consumer(consumer_node)
    return if has_consumer_node? consumer_node

    consumer_node.affiliate self, DistributionPluginNode::Roles.consumer(self.profile.environment)
    supplier = DistributionPluginSupplier.create!(:node => self, :consumer => consumer_node) || suppliers.from_node(consumer_node)

    consumer_node.add_supplier_products supplier unless consumer_node.consumer?
    supplier
  end
  def remove_consumer(consumer_node)
    consumer_node.disaffiliate self, DistributionPluginNode::Roles.consumer(self.profile.environment)
    supplier = consumers.find_by_consumer_id(consumer_node.id)

    supplier.destroy if supplier
    supplier
  end

  def add_supplier_products(supplier)
    raise "'#{supplier.name}' is not a supplier of #{self.profile.name}" unless has_supplier?(supplier)

    already_supplied = self.products.unarchived.distributed.from_supplier(supplier).all
    supplier.products.unarchived.each do |np|
      next if already_supplied.find{ |f| f.supplier_product == np }

      p = DistributionPluginDistributedProduct.new :node => self
      p.distribute_from np
    end
  end

  def not_distributed_products(supplier)
    raise "'#{supplier.name}' is not a supplier of #{self.profile.name}" unless has_supplier?(supplier)

    supplier.node.products.unarchived.own.distributed - self.from_products.unarchived.distributed.by_node(supplier.node)
  end

  def has_admin?(node)
    if node and node.profile
      node.profile.has_permission? 'edit_profile', self.profile
    end
  end

  alias_method :destroy!, :destroy
  def destroy
    self.products.distributed.update_all ['archived = true']
    destroy!
  end

  def enable_collective_view
    self.add_order_block
    self.profile.update_attribute :theme, 'distribution'

    login_block = self.profile.blocks.select{ |b| b.class.name == "LoginBlock" }.first
    if not login_block
      box = self.profile.boxes.first :conditions => {:position => 2}
      login_block = LoginBlock.create! :box => box
      login_block.move_to_top
    end

    self.profile.home_page = self.profile.blogs.first
    self.profile.save!
  end
  def disable_collective_view
    self.profile.update_attribute :theme, nil

    order_block = self.profile.blocks.select{ |b| b.class.name == "DistributionPlugin::OrderBlock" }.first
    order_block.destroy if order_block

    login_block = self.profile.blocks.select{ |b| b.class.name == "LoginBlock" }.first
    login_block.destroy if login_block
  end

  def add_order_block
    return unless self.profile.blocks.select{ |b| b.class.name == "DistributionPlugin::OrderBlock" }.first

    boxes = self.profile.boxes.select{ |box| !box.blocks.collect{ |b| b.class.name }.include?("MainBlock") }
    box = boxes.count > 1 ? boxes.max{ |a,b| a.position <=> b.position } : Box.create(:owner => self.profile, :position => 3)
    block = DistributionPlugin::OrderBlock.create! :box => box, :display => 'except_home_page'
    block.move_to_top
  end

  protected

  def add_self_supplier
    self_supplier
  end

  def add_own_members
    profile.members.map do |member|
      consumer = DistributionPluginNode.find_or_create member
      add_consumer consumer
      consumer
    end
  end

  def add_own_products
    return unless profile.respond_to? :products

    already_supplied = self.products.unarchived.distributed.from_supplier(self).all
    profile.products.map do |p|
      already_supplied.find{ |f| f.product == p } ||
        DistributionPluginDistributedProduct.create!(:node => self, :supplier => self_supplier, :product => p, :name => p.name, :description => p.description, :price => p.price, :unit => p.unit)
    end
  end

  def save_image
    image.save if image
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

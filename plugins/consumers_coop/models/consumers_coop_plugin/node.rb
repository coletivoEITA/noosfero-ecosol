class DistributionPlugin::Node < Noosfero::Plugin::ActiveRecord

  belongs_to :profile

  has_many :sessions, :class_name => 'OrdersCyclePlugin::Cycle', :foreign_key => :node_id, :dependent => :destroy, :order => 'created_at DESC',
    :conditions => ["orders_cycle_plugin_cycles.status <> 'new'"]
  has_many :orders, :through => :sessions, :source => :orders, :order => 'id ASC'
  has_many :parcels, :class_name => 'OrdersPlugin::Order', :foreign_key => :consumer_id, :order => 'id ASC'

  has_many :products, :through => :profile, :class_name => 'SuppliersPlugin::DistributedProduct', :order => 'products.name ASC'
  has_many :offered_products, :through => :profile, :order => 'products.name ASC'
  has_many :order_products, :through => :orders, :source => :offered_products, :order => 'name ASC'
  has_many :parcel_products, :through => :parcels, :source => :offered_products, :order => 'id ASC'
  has_many :supplier_products, :through => :suppliers, :source => :products, :order => 'name ASC'
  has_many :consumer_products, :through => :consumers, :source => :consumer_products, :order => 'id ASC'

  has_many :from_products, :through => :products
  has_many :to_products, :through => :products
  has_many :from_nodes, :through => :products
  has_many :to_nodes, :through => :products

  has_many :sessions_custom_order, :class_name => 'OrdersCyclePlugin::Cycle', :foreign_key => :node_id, :dependent => :destroy,
    :conditions => ["orders_cycle_plugin_cycles.status <> 'new'"]

  acts_as_having_image
  belongs_to :image, :class_name => 'DistributionPlugin::HeaderImage'

  validates_presence_of :profile
  validates_inclusion_of :role, :in => ['supplier', 'collective', 'consumer']

  after_create :add_self_supplier
  after_create :add_own_members
  after_create :add_own_products
  after_update :save_image
  before_create :check_roles

  def self.find_or_create(profile)
    find_by_profile_id(profile.id) || create!(:profile => profile, :role => 'consumer')
  end

  def abbreviation_or_name
    self['name_abbreviation'] || name
  end

  def enabled?
    !self.consumer?
  end
  def consumer?
    self.role == 'consumer'
  end
  def supplier?
    self.role == 'supplier'
  end
  def collective?
    self.role == 'collective'
  end

  def dummy?
    !self.profile.visible
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

  def default_open_sessions_products_margins
    self.class.transaction do
      sessions.open.each do |session|
        session.products.each do |product|
          product.margin_percentage = margin_percentage
          product.save!
        end
      end
    end
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
      consumer = DistributionPlugin::Node.find_or_create member
      add_consumer consumer
      consumer
    end
  end

  def add_own_products
    return unless profile.respond_to? :products

    already_supplied = self.products.unarchived.distributed.from_supplier_id(self.self_supplier.id).all
    profile.products.map do |p|
      already_supplied.find{ |f| f.product == p } ||
        SuppliersPlugin::DistributedProduct.create!(:node => self, :supplier => self_supplier, :product => p, :name => p.name, :description => p.description, :price => p.price, :unit => p.unit)
    end
  end

  def save_image
    image.save if image
  end

  def method_missing method, *args, &block
    if self.profile.respond_to? method
      self.profile.send method, *args, &block
    else
      super method, *args, &block
    end
  end

end

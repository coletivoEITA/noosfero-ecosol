class SuppliersPlugin::Supplier < Noosfero::Plugin::ActiveRecord

  belongs_to :profile
  belongs_to :consumer, :class_name => 'Profile'
  alias_method :supplier, :profile

  validates_presence_of :name, :if => :dummy?
  validates_associated :profile, :if => :dummy?
  validates_presence_of :profile
  validates_presence_of :consumer
  validates_uniqueness_of :consumer_id, :scope => :profile_id, :if => :profile_id

  named_scope :active, :conditions => {:active => true}

  named_scope :of_profile, lambda { |p| { :conditions => {:profile_id => p.id} } }
  named_scope :of_profile_id, lambda { |id| { :conditions => {:profile_id => id} } }
  named_scope :of_consumer, lambda { |c| { :conditions => {:consumer => c.id} } }
  named_scope :of_consumer_id, lambda { |id| { :conditions => {:consumer_id => id} } }

  named_scope :from_supplier_id, lambda { |supplier_id| {
      :conditions => ['suppliers_plugin_source_products.supplier_id = ?', supplier_id],
      :joins => 'INNER JOIN suppliers_plugin_source_products ON products.id = suppliers_plugin_source_products.to_product_id'
    }
  }

  named_scope :with_name, lambda { |name| if name then {:conditions => ["LOWER(suppliers_plugin_suppliers.name) LIKE ?","%#{name.downcase}%"]} else {} end }
  named_scope :by_active, lambda { |active| if active then {:conditions => {:active => active}} else {} end }

  named_scope :except_people, { :conditions => ['profiles.type <> ?', Person.name], :joins => [:consumer] }
  named_scope :except_self, { :conditions => 'profile_id <> consumer_id' }

  after_create :add_admins, :if => :dummy?
  after_create :save_profile, :if => :dummy?
  after_create :distribute_products_to_consumer

  attr_accessor :dont_destroy_dummy

  def self.new_dummy attributes
    profile = Enterprise.new :enabled => false, :visible => false, :public_profile => false,
      :identifier => Digest::MD5.hexdigest(rand.to_s), :environment => attributes[:consumer].environment
    supplier = self.new :profile => profile
    supplier.attributes = attributes
    supplier
  end
  def self.create_dummy attributes
    s = new_dummy attributes
    s.save!
    s
  end

  def self?
    profile == consumer
  end
  def person?
    self.consumer.person?
  end
  def dummy?
    !self.supplier.visible
  end
  def active?
    self.active
  end

  def name
    self.attributes['name'] || self.profile.name
  end
  def name= value
    self['name'] = value
    self.supplier.name = value if self.dummy? and not self.supplier.frozen?
  end
  def description
    self.attributes['description'] || self.profile.description
  end
  def description= value
    self['description'] = value
    self.supplier.description = value if self.dummy? and not self.supplier.frozen?
  end

  def abbreviation_or_name
    return self.profile.nickname || self.name if self.self?
    self.name_abbreviation.blank? ? self.name : self.name_abbreviation
  end

  def destroy_with_dummy
    if not self.self? and not self.dont_destroy_dummy and self.supplier.dummy?
      self.supplier.destroy
    end
    self.destroy_without_dummy
  end
  alias_method_chain :destroy, :dummy

  protected

  def add_admins
    self.consumer.admins.each{ |a| self.supplier.add_admin a }
  end

  # sync name, description, etc
  def save_profile
    self.supplier.save
  end

  def distribute_products_to_consumer
    return if self.self? or self.consumer.person?

    already_supplied = self.consumer.distributed_products.unarchived.from_supplier_id(self.id).all

    self.profile.products.unarchived.each do |source_product|
      next if already_supplied.find{ |f| f.supplier_product == source_product }

      source_product.distribute_to_consumer self.consumer
    end
  end

  # delegate missing methods to profile
  def method_missing method, *args, &block
    if self.profile.respond_to? method
      self.profile.send method, *args, &block
    else
      super method, *args, &block
    end
  end
  def respond_to_with_profile? method
    respond_to_without_profile? method or Profile.new.respond_to? method
  end
  alias_method_chain :respond_to?, :profile

end

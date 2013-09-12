class SuppliersPlugin::Supplier < Noosfero::Plugin::ActiveRecord

  belongs_to :profile
  belongs_to :consumer, :class_name => 'Profile'
  belongs_to :supplier, :foreign_key => :profile_id, :class_name => 'Profile'

  has_many :products, :through => :profile, :class_name => 'SuppliersPlugin::DistributedProduct'
  has_many :consumer_products, :through => :consumer, :source => :products, :class_name => 'SuppliersPlugin::DistributedProduct'

  validates_presence_of :profile
  validates_presence_of :consumer
  validates_associated :profile
  validates_uniqueness_of :consumer_id, :scope => :profile_id

  named_scope :of_profile, lambda { |n| { :conditions => {:profile_id => n.id} } }
  named_scope :of_profile_id, lambda { |id| { :conditions => {:profile_id => id} } }
  named_scope :of_consumer_id, lambda { |id| { :conditions => {:consumer_id => id} } }

  named_scope :with_name, lambda { |name| { :conditions => ["LOWER(suppliers_plugin_suppliers.name) LIKE ?","%#{name.downcase}%"] } }

  named_scope :from_supplier_id, lambda { |supplier_id| {
      :conditions => ['suppliers_plugin_source_products.supplier_id = ?', supplier_id],
      :joins => 'INNER JOIN suppliers_plugin_source_products ON products.id = suppliers_plugin_source_products.to_product_id'
    }
  }

  named_scope :active, :conditions => {:active => true}
  named_scope :by_active, lambda { |n| {:conditions => {:active => n} } }

  named_scope :except_people, { :conditions => ['profiles.type <> ?', Person.name], :joins => [:consumer] }
  named_scope :except_self, { :conditions => 'profile_id <> consumer_id' }

  after_create :add_admins_if_dummy

  def self.new_dummy attributes
    profile = Enterprise.new :visible => false, :identifier => Digest::MD5.hexdigest(rand.to_s),
      :environment => attributes[:consumer].environment
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

  def abbreviation_or_name
    name_abbreviation.blank? ? name : name_abbreviation
  end

  def name= value
    self['name'] = value
    if dummy?
      self.profile.name = value
      self.profile.save!
    end
  end

  # FIXME: archive instead of deleting
  def destroy
    profile.destroy if profile.dummy?
    consumer_products.from_supplier_id(self.id).distributed.update_all({:archived => true})

    super
  end

  protected

  def add_admins_if_dummy
    if dummy?
      self.consumer.admins.each{ |a| self.supplier.add_admin a }
    end
  end

  # delete missing methods to profile
  def method_missing method, *args, &block
    if self.profile.respond_to? method
      self.profile.send method, *args, &block
    else
      super method, *args, &block
    end
  end
  def respond_to_with_profile? method
    respond_to_without_profile? method or self.profile.respond_to? method
  end
  alias_method_chain :respond_to?, :profile

end

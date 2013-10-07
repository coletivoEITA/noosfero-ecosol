class SuppliersPlugin::Supplier < Noosfero::Plugin::ActiveRecord

  belongs_to :profile
  belongs_to :consumer, :class_name => 'Profile'
  def supplier
    self.profile
  end

  validates_presence_of :profile
  validates_presence_of :consumer
  validates_associated :profile
  validates_uniqueness_of :consumer_id, :scope => :profile_id

  named_scope :active, :conditions => {:active => true}

  named_scope :of_profile, lambda { |n| { :conditions => {:profile_id => n.id} } }
  named_scope :of_profile_id, lambda { |id| { :conditions => {:profile_id => id} } }
  named_scope :of_consumer_id, lambda { |id| { :conditions => {:consumer_id => id} } }

  named_scope :from_supplier_id, lambda { |supplier_id| {
      :conditions => ['suppliers_plugin_source_products.supplier_id = ?', supplier_id],
      :joins => 'INNER JOIN suppliers_plugin_source_products ON products.id = suppliers_plugin_source_products.to_product_id'
    }
  }

  named_scope :with_name, lambda { |name| name ? {:conditions => ["LOWER(suppliers_plugin_suppliers.name) LIKE ?","%#{name.downcase}%"]} : {} }
  named_scope :by_active, lambda { |active| active ? {:conditions => {:active => active}} : {} }

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
  def name= value
    self['name'] = value
    if dummy?
      self.supplier.name = value
      self.supplier.save!
    end
  end
  def description
    self.attributes['description'] || self.profile.description
  end
  def description= value
    self['description'] = value
    if dummy?
      self.supplier.description = value
      self.supplier.save!
    end
  end

  def abbreviation_or_name
    return self.profile.nickname || self.name if self.self?
    self.name_abbreviation.blank? ? self.name : self.name_abbreviation
  end

  def destroy_with_dummy
    return if self.self?
    # FIXME: archive instead of deleting
    self.supplier.destroy if self.supplier.dummy?
    destroy_without_dummy
  end
  def destroy_with_products
    return if self.self?
    self.consumer.products.from_supplier_id(self.id).each do |product|
      product.update_attribute :archived, true
    end
    destroy_without_products
  end
  alias_method_chain :destroy, :dummy
  alias_method_chain :destroy, :products

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
    respond_to_without_profile? method or Profile.new.respond_to? method
  end
  alias_method_chain :respond_to?, :profile

end

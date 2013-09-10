class SuppliersPlugin::Supplier < Noosfero::Plugin::ActiveRecord

  belongs_to :profile
  belongs_to :consumer, :class_name => 'Profile'

  has_many :products, :through => :profile, :class_name => 'SuppliersPlugin::DistributedProduct'
  has_many :consumer_products, :through => :consumer, :source => :products, :class_name => 'SuppliersPlugin::DistributedProduct'

  validates_presence_of :profile
  validates_presence_of :consumer
  validates_associated :profile
  validates_uniqueness_of :consumer_id, :scope => :profile_id

  named_scope :of_profile, lambda { |n| { :conditions => {:profile_id => n.id} } }
  named_scope :of_profile_id, lambda { |id| { :conditions => {:profile_id => id} } }
  named_scope :of_consumer_id, lambda { |id| { :conditions => {:consumer_id => id} } }

  named_scope :with_name, lambda { |name| { :conditions => ["LOWER(name) LIKE ?","%#{name.downcase}%"] } }

  named_scope :from_supplier_id, lambda { |supplier_id| {
      :conditions => ['suppliers_plugin_source_products.supplier_id = ?', supplier_id],
      :joins => 'INNER JOIN suppliers_plugin_source_products ON products.id = suppliers_plugin_source_products.to_product_id'
    }
  }

  named_scope :active, :conditions => {:active => true}

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

  def dummy?
    !profile.visible
  end

  def active?
    self.active
  end

  def name
    attributes['name'] || self.profile.name
  end

  def abbreviation_or_name
    name_abbreviation.blank? ? name : name_abbreviation
  end

  def name=(value)
    self['name'] = value
    if dummy?
      self.profile.name = value
      self.profile.save!
    end
  end

  # FIXME: inactivate instead of deleting
  def destroy
    profile.destroy if profile.dummy?
    consumer_products.from_supplier_id(self.id).distributed.update_all({:archived => true})

    super
  end

  protected

  after_create :complete
  def complete
    if dummy?
      consumer.admins.each{ |a| profile.add_admin(a) } if profile.dummy?
    end
  end

  def method_missing method, *args, &block
    if self.profile.respond_to? method
      self.profile.send method, *args, &block
    else
      super method, *args, &block
    end
  end
  def respond_to? method
    super method or self.profile.respond_to? method
  end

end

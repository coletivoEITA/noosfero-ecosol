class SuppliersPlugin::Supplier < Noosfero::Plugin::ActiveRecord

  belongs_to :profile
  belongs_to :consumer, :class_name => 'Profile'

  has_many :supplied_products, :foreign_key => 'supplier_id', :class_name => 'SuppliersPlugin::BaseProduct', :order => 'name ASC'

  named_scope :of_profile, lambda { |n| { :conditions => {:profile_id => n.id} } }
  named_scope :of_profile_id, lambda { |id| { :conditions => {:profile_id => id} } }

  named_scope :with_name, lambda { |name| { :conditions => ["LOWER(name) LIKE ?",'%'+name.downcase+'%']  } }

  validates_presence_of :profile
  validates_presence_of :consumer
  validates_associated :profile
  validates_uniqueness_of :consumer_id, :scope => :profile_id

  def self.new_dummy(attributes)
    profile = Enterprise.new :visible => false, :identifier => Digest::MD5.hexdigest(rand.to_s),
      :environment => attributes[:consumer].environment
    supplier = self.new :profile => profile
    supplier.attributes = attributes
    supplier
  end
  def self.create_dummy(attributes)
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

  alias_method :destroy_orig, :destroy
  def destroy!
    supplied_products.each{ |p| p.destroy! }
    destroy_orig
  end

  # FIXME: inactivate instead of deleting
  def destroy
    profile.destroy if profile.dummy?
    supplied_products.distributed.update_all({:archived => true})

    super
  end

  protected

  after_create :complete
  def complete
    if dummy?
      consumer.profile.admins.each{ |a| profile.add_admin(a) } if profile.dummy?
    end
  end

end

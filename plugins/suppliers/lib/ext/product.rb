require_dependency 'product'

class Product

  named_scope :available, :conditions => {:available => true}
  named_scope :inavailable, :conditions => {:available => false}
  named_scope :archived, :conditions => {:archived => true}
  named_scope :unarchived, :conditions => {:archived => false}

  named_scope :with_available, lambda { |available| { :conditions => {:available => available} } }

  # FIXME: transliterate input and on db
  named_scope :name_like, lambda { |name| { :conditions => ["LOWER(products.name) LIKE ?", "%#{name}%"] } }

  named_scope :by_profile, lambda { |profile| { :conditions => {:profile_id => profile.id} } }
  named_scope :by_profile_id, lambda { |profile_id| { :conditions => {:profile_id => profile_id} } }

  # the above code should be on the core

  has_many :sources_from_products, :class_name => 'SuppliersPlugin::SourceProduct', :foreign_key => :to_product_id, :dependent => :destroy
  has_many :sources_to_products, :class_name => 'SuppliersPlugin::SourceProduct', :foreign_key => :from_product_id, :dependent => :destroy

  has_many :suppliers, :through => :sources_from_products, :order => 'id ASC'

  has_many :to_products, :through => :sources_to_products, :order => 'id ASC'
  has_many :from_products, :through => :sources_from_products, :order => 'id ASC'
  def from_product
    self.from_products.first
  end

  # join source_products
  default_scope :include => [:from_products]

  named_scope :distributed, :conditions => ["products.type = 'SuppliersPlugin::DistributedProduct'"]

  named_scope :from_supplier_profile_id, lambda { |profile_id| {
      :conditions => ['suppliers_plugin_suppliers.profile_id = ?', profile_id],
      :joins => 'INNER JOIN suppliers_plugin_suppliers ON suppliers_plugin_suppliers.profile_id = suppliers_plugin_source_products.supplier_id'
    }
  }
  named_scope :from_supplier_id, lambda { |supplier_id| {
      :conditions => ['suppliers_plugin_source_products.supplier_id = ?', supplier_id],
    }
  }

  named_scope :own,
    :conditions => ['products.profile_id = suppliers_plugin_source_products.to_product_id AND suppliers_plugin_source_products.from_product_id IS NULL'],
    :joins => 'INNER JOIN suppliers_plugin_source_products ON suppliers_plugin_source_products.to_product_id = products.id '

  extend CurrencyHelper::ClassMethods
  has_currency :price

  after_create :distribute_to_consumers

  def supplier
    @supplier ||= self.from_product.supplier if self.from_product
    @supplier ||= self.profile.self_supplier
  end
  def supplier= value
    @supplier = value
  end
  def supplier_id
    self.supplier.id if self.supplier
  end
  def supplier_id= id
    @supplier = profile.environment.profiles.find id
  end

  def own?
    self.supplier.profile == self.profile
  end
  def supplier_dummy?
    self.supplier ? self.supplier.dummy? : false
  end

  def supplier_products
    self.from_products
  end
  def supplier_product
    self.supplier_products.first
  end

  protected

  # see also #distribute_supplier_products
  def distribute_to_consumers
    self.profile.consumers.except_people.except_self.each do |consumer|
      SuppliersPlugin::DistributedProduct.create! :profile => consumer.profile, :from_products => [self]
    end
  end

end

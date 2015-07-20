require_dependency 'product'

# FIXME: The lines bellow should be on the core
class Product

  extend CurrencyHelper::ClassMethods
  has_currency :price
  has_currency :discount

  scope :alphabetically, -> { order 'products.name ASC' }

  scope :available, -> { where available: true }
  scope :unavailable, -> { where 'products.available <> true' }
  scope :archived, -> { where archived: true }
  scope :unarchived, -> { where 'products.archived <> true' }

  scope :with_available, -> (available) { where available: available }
  scope :with_price, -> { where 'products.price > 0' }
  scope :with_product_category_id, -> (id) { where product_category_id: id }

  # FIXME: transliterate input and name column
  scope :name_like, -> (name) { where "LOWER(products.name) LIKE ?", "%#{name}%" }

  scope :by_profile, -> (profile) { where profile_id: profile.id }
  scope :by_profile_id, -> (profile_id) { where profile_id: profile_id }

  def self.product_categories_of products
    ProductCategory.find products.collect(&:product_category_id).compact.select{ |id| not id.zero? }
  end

  attr_accessible :external_id
  settings_items :external_id, type: String, default: nil

  # should be on core, used by SuppliersPlugin::Import
  attr_accessible :price_details

end

class Product

  attr_accessible :from_products, :supplier_id, :supplier

  has_many :sources_from_products, foreign_key: :to_product_id, class_name: 'SuppliersPlugin::SourceProduct', dependent: :destroy
  has_many :sources_to_products, foreign_key: :from_product_id, class_name: 'SuppliersPlugin::SourceProduct', dependent: :destroy
  has_many :to_products, -> { order 'id ASC' }, through: :sources_to_products
  has_many :from_products, -> { order 'id ASC' }, through: :sources_from_products
  def from_product
    self.from_products.first
  end

  # defined just as *from_products above
  # may be overriden in different subclasses
  has_many :sources_supplier_products, foreign_key: :to_product_id, class_name: 'SuppliersPlugin::SourceProduct'
  has_many :supplier_products, -> { order 'id ASC' }, through: :sources_from_products, source: :from_product

  has_many :sources_from_2x_products, through: :sources_from_products, source: :sources_from_products
  has_many :sources_to_2x_products, through: :sources_to_product, source: :sources_to_products
  has_many :from_2x_products, through: :sources_from_2x_products, source: :from_product
  has_many :to_2x_products, through: :sources_to_2x_products, source: :to_product

  has_many :suppliers, -> { uniq.order 'id ASC' }, through: :sources_from_products
  has_many :consumers, -> { uniq.order 'id ASC' }, through: :to_products, source: :profile

  # prefer distributed_products has_many to use DistributedProduct scopes and eager loading
  scope :distributed, -> { where "products.type = 'SuppliersPlugin::DistributedProduct'" }
  scope :own, -> { where "products.type = 'Product'" }

  scope :from_supplier, -> (supplier) { joins(:suppliers).where 'suppliers_plugin_suppliers.id = ?', supplier.id }
  scope :from_supplier_id, -> (supplier_id) { joins(:suppliers).where 'suppliers_plugin_suppliers.id = ?', supplier_id }

  after_create :distribute_to_consumers

  def own?
    self.class == Product
  end
  def distributed?
    self.class == SuppliersPlugin::DistributedProduct
  end

  def sources_supplier_product
    self.supplier_products.load_target unless self.supplier_products.loaded?
    self.sources_supplier_products.first
  end
  def supplier_product
    self.supplier_products.load_target unless self.supplier_products.loaded?
    self.supplier_products.first
  end

  def supplier
    # FIXME: use self.suppliers when rails support for nested preload comes
    @supplier ||= self.sources_supplier_product.supplier rescue nil
    @supplier ||= self.profile.self_supplier rescue nil
  end
  def supplier= value
    @supplier = value
  end
  def supplier_id
    self.supplier.id
  end
  def supplier_id= id
    @supplier = profile.environment.profiles.find id
  end

  def supplier_dummy?
    self.supplier ? self.supplier.dummy? : self.profile.dummy?
  end

  def distribute_to_consumer consumer, attrs = {}
    distributed_product = consumer.distributed_products.where(profile_id: consumer.id, from_products_products: {id: self.id}).first
    distributed_product ||= SuppliersPlugin::DistributedProduct.create! profile: consumer, from_products: [self]
    distributed_product.update_attributes! attrs if attrs.present?
    distributed_product
  end

  def destroy_dependent
    self.to_products.each do |to_product|
      to_product.destroy if to_product.dependent?
    end
  end

  # before_destroy and after_destroy don't work,
  # see http://stackoverflow.com/questions/14175330/associations-not-loaded-in-before-destroy-callback
  def destroy
    self.class.transaction do
      self.destroy_dependent
      super
    end
  end

  protected

  def distribute_to_consumers
    # shopping_cart creates products without a profile...
    return unless self.profile

    self.profile.consumers.except_people.except_self.each do |consumer|
      self.distribute_to_consumer consumer.profile
    end
  end

end

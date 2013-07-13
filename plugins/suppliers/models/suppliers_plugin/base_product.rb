# FIXME remove Base when plugin became a module
class SuppliersPlugin::BaseProduct < Product

  belongs_to :category, :class_name => 'ProductCategory'
  belongs_to :type_category, :class_name => 'ProductCategory'

  named_scope :by_profile, lambda { |profile| { :conditions => {:profile_id => profile.id} } }
  named_scope :by_profile_id, lambda { |profile_id| { :conditions => {:profile_id => profile_id} } }
  named_scope :from_supplier, lambda { |supplier| supplier.nil? ? {} : { :conditions => {:supplier_id => supplier.id} } }

  named_scope :distributed, :conditions => ["products.type = 'SuppliersPlugin::DistributedProduct'"]

  named_scope :own,
    :select => 'products.*',
    :from => 'products, suppliers_plugin_suppliers',
    :conditions => ['products.profile_id = suppliers_plugin_suppliers.profile_id'],
    :joins => 'INNER JOIN suppliers_plugin_source_products ON products.id = suppliers_plugin_source_products.to_product_id ' +
      'INNER JOIN suppliers_plugin_suppliers ON suppliers_plugin_source_products.supplier_id = suppliers_plugin_suppliers.id '
  named_scope :active, :conditions => {:active => true}
  named_scope :inactive, :conditions => {:active => false}
  named_scope :archived, :conditions => {:archived => true}
  named_scope :unarchived, :conditions => {:archived => false}

  has_many :sources_from_products, :class_name => 'SuppliersPlugin::SourceProduct', :foreign_key => :to_product_id
  has_many :sources_to_products, :class_name => 'SuppliersPlugin::SourceProduct', :foreign_key => :from_product_id, :dependent => :destroy

  has_many :suppliers, :through => :sources_from_products, :order => 'id ASC'

  has_many :to_products, :through => :sources_to_products, :order => 'id ASC'
  has_many :from_products, :through => :sources_from_products, :order => 'id ASC'
  has_many :to_profiles, :through => :to_products, :source => :profile
  has_many :from_profiles, :through => :from_products, :source => :profile

  settings_items :minimum_selleable, :type => Float, :default => nil
  settings_items :margin_percentage, :type => Float, :default => nil
  settings_items :margin_fixed, :type => Float, :default => nil
  settings_items :stored, :type => Float, :default => nil
  settings_items :quantity, :type => Float, :default => nil
  settings_items :category_id
  settings_items :type_category_id

  validates_presence_of :name, :if => Proc.new { |p| !p.dummy? }
  # disable name validation
  validates_uniqueness_of :name, :scope => :profile_id, :allow_nil => true, :if => proc{ |p| false }

  validates_associated :from_products

  DEFAULT_ATTRIBUTES = [:name, :description, :margin_percentage, :margin_fixed,
    :price, :stored, :unit_id, :minimum_selleable, :unit_detail]

  extend ActsAsHavingSettings::DefaultItem::ClassMethods
  settings_default_item :name, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :description, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :price, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :stored, :type => :boolean, :default => true, :delegate_to => :from_product
  default_item :unit_id, :if => :default_price, :delegate_to => :from_product
  default_item :minimum_selleable, :if => :default_price, :delegate_to => :from_product
  default_item :unit_detail, :if => :default_price, :delegate_to => :from_product

  extend SuppliersPlugin::CurrencyHelper::ClassMethods
  has_number_with_locale :minimum_selleable
  has_number_with_locale :own_minimum_selleable
  has_number_with_locale :original_minimum_selleable
  has_number_with_locale :margin_percentage
  has_number_with_locale :own_margin_percentage
  has_number_with_locale :original_margin_percentage
  has_number_with_locale :margin_fixed
  has_number_with_locale :own_margin_fixed
  has_number_with_locale :original_margin_fixed
  has_number_with_locale :stored
  has_number_with_locale :own_stored
  has_number_with_locale :original_stored
  has_number_with_locale :quantity
  has_currency :price
  has_currency :own_price
  has_currency :original_price

  def self.default_unit
    Unit.new(:singular => I18n.t('distribution_plugin.models.product.unit'), :plural => I18n.t('distribution_plugin.models.product.units'))
  end

  def dummy?
    supplier ? supplier.dummy? : false
  end
  def own?
    supplier ? supplier.node == node : false
  end

  def from_product
    self.from_products.first
  end
  def from_product= value
    self.from_products = [value]
  end

  def supplier
    self.from_product
  end
  def supplier= value
    self.from_product.supplier = value if self.from_product
  end

  def supplier_products
    self.from_products
  end
  def supplier_product
    r = self.supplier_products.first
    return r if r

    # automatically create a product if supplier is dummy
    if !own? and dummy?
      @supplier_product ||= SuppliersPlugin::DistributedProduct.new :profile => supplier.node
    end

    @supplier_product
  end
  def supplier_product=(value)
    if value.is_a?(Hash)
      supplier_product.attributes = value if supplier_product
    else
      @supplier_product = value
    end
  end

  def minimum_selleable
    self['minimum_selleable'] || 0.1
  end

  def price_with_margins(base_price = nil, margin_source = nil)
    price = 0 unless price
    base_price ||= price
    margin_source ||= self
    ret = base_price

    if margin_source.margin_percentage
      ret += (margin_source.margin_percentage / 100) * ret
    elsif node.margin_percentage
      ret += (node.margin_percentage / 100) * ret
    end
    if margin_source.margin_fixed
      ret += margin_source.margin_fixed
    elsif node.margin_fixed
      ret += node.margin_fixed
    end

    ret
  end

  def unit
    self['unit'] || self.class.default_unit
  end

  def archive
    self.update_attributes! :archived => true
  end
  def unarchive
    self.update_attributes! :archived => false
  end

  alias_method :destroy!, :destroy
  def destroy
    raise "Products shouldn't be destroyed for the sake of the history!"
  end

  protected

end

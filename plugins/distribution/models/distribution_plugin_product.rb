class DistributionPluginProduct < ActiveRecord::Base

  belongs_to :node, :class_name => 'DistributionPluginNode'
  belongs_to :supplier, :class_name => 'DistributionPluginSupplier'

  named_scope :by_node, lambda { |n| { :conditions => {:node_id => n.id} } }
  named_scope :by_node_id, lambda { |id| { :conditions => {:node_id => id} } }
  named_scope :from_supplier, lambda { |supplier| supplier.nil? ? {} : { :conditions => {:supplier_id => supplier.id} } }

  # optional fields
  belongs_to :product
  belongs_to :unit

  has_one :product_category, :through => :product

  belongs_to :category, :class_name => 'ProductCategory'
  belongs_to :type_category, :class_name => 'ProductCategory'

  named_scope :distributed, :conditions => ['distribution_plugin_products.session_id is null']
  named_scope :in_session, :conditions => ['distribution_plugin_products.session_id is not null']
  named_scope :for_session, lambda { |session| { :conditions => {:session_id => session.id} } }

  named_scope :own,
    :select => 'distribution_plugin_products.*',
    :conditions => ['distribution_plugin_products.node_id = distribution_plugin_suppliers.node_id'],
    :joins => 'INNER JOIN distribution_plugin_suppliers ON distribution_plugin_products.supplier_id = distribution_plugin_suppliers.id'
  named_scope :active, :conditions => {:active => true}
  named_scope :inactive, :conditions => {:active => false}
  named_scope :archived, :conditions => {:archived => true}
  named_scope :unarchived, :conditions => {:archived => false}

  has_many :sources_from_products, :class_name => 'DistributionPluginSourceProduct', :foreign_key => 'to_product_id'
  has_many :sources_to_products, :class_name => 'DistributionPluginSourceProduct', :foreign_key => 'from_product_id', :dependent => :destroy

  has_many :to_products, :through => :sources_to_products, :order => 'id asc'
  has_many :from_products, :through => :sources_from_products, :order => 'id asc'
  has_many :to_nodes, :through => :to_products, :source => :node
  has_many :from_nodes, :through => :from_products, :source => :node

  def from_product
    self.from_products.first
  end
  def from_product=(value)
    self.from_products = [value]
  end
  def supplier_products
    self.supplier.nil? ? self.from_products : self.from_products.select{ |fp| fp.node == self.supplier.node }
  end
  def supplier_product
    self.supplier_products.first
  end

  validates_presence_of :type
  validates_presence_of :node
  validates_presence_of :name, :if => Proc.new { |p| !p.dummy? }
  validates_associated :from_products
  validates_numericality_of :price, :allow_nil => true
  validates_numericality_of :minimum_selleable, :allow_nil => true
  validates_numericality_of :margin_percentage, :allow_nil => true
  validates_numericality_of :margin_fixed, :allow_nil => true
  validates_numericality_of :stored, :allow_nil => true
  validates_numericality_of :quantity, :allow_nil => true

  acts_as_having_settings :field => :settings

  DEFAULT_ATTRIBUTES = [:name, :description, :margin_percentage, :margin_fixed,
    :price, :stored, :unit_id, :minimum_selleable, :unit_detail]

  extend ActsAsHavingSettings::DefaultItem::ClassMethods
  settings_default_item :name, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :description, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :margin_percentage, :type => :boolean, :default => true, :delegate_to => :node
  settings_default_item :margin_fixed, :type => :boolean, :default => true, :delegate_to => :node
  settings_default_item :price, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :stored, :type => :boolean, :default => true, :delegate_to => :from_product
  default_item :unit_id, :if => :default_price, :delegate_to => :from_product
  default_item :minimum_selleable, :if => :default_price, :delegate_to => :from_product
  default_item :unit_detail, :if => :default_price, :delegate_to => :from_product

  extend DistributionPlugin::DistributionCurrencyHelper::ClassMethods
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

  def minimum_selleable
    self['minimum_selleable'] || 0.1
  end

  def dummy?
    supplier ? supplier.dummy? : false
  end
  def own?
    supplier ? supplier.node == node : false
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

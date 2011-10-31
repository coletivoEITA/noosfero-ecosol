class DistributionPluginProduct < ActiveRecord::Base

  default_scope :conditions => {:archived => false}

  belongs_to :node, :class_name => 'DistributionPluginNode'
  belongs_to :supplier, :class_name => 'DistributionPluginSupplier'

  named_scope :by_node, lambda { |n| { :conditions => {:node_id => n.id} } }
  named_scope :by_node_id, lambda { |id| { :conditions => {:node_id => id} } }
  named_scope :from_supplier, lambda { |supplier| supplier.nil? ? {} : { :conditions => {:supplier_id => supplier.id} } }

  #optional fields
  belongs_to :product
  belongs_to :unit

  has_one :product_category, :through => :product

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

  #must be overriden on subclasses
  def supplier_products
    []
  end

  validates_presence_of :node
  validates_presence_of :name, :if => Proc.new { |p| !p.dummy? }
  validates_associated :from_products
  validates_numericality_of :price, :allow_nil => true
  validates_numericality_of :minimum_selleable, :allow_nil => true
  validates_numericality_of :selleable_factor, :allow_nil => true
  validates_numericality_of :margin_percentage, :allow_nil => true
  validates_numericality_of :margin_fixed, :allow_nil => true
  validates_numericality_of :stored, :allow_nil => true
  validates_numericality_of :quantity, :allow_nil => true
  validate :supplier_change

  extend ActsAsHavingSettings::DefaultItem::ClassMethods
  acts_as_having_settings :field => :settings

  DEFAULT_ATTRIBUTES = [:name, :description, :margin_percentage, :margin_fixed,
    :price, :stored, :unit_id, :minimum_selleable, :selleable_factor]

  settings_default_item :name, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :description, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :margin_percentage, :type => :boolean, :default => true, :delegate_to => :node
  settings_default_item :margin_fixed, :type => :boolean, :default => true, :delegate_to => :node
  settings_default_item :price, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :stored, :type => :boolean, :default => true, :delegate_to => :from_product
  default_item :unit_id, :if => :default_price, :delegate_to => :from_product
  default_item :minimum_selleable, :if => :default_price, :delegate_to => :from_product
  default_item :selleable_factor, :if => :default_price, :delegate_to => :from_product

  def dummy?
    supplier ? supplier.dummy? : false
  end

  def own?
    supplier ? supplier.node == node : false
  end

  def from_product
    from_products.first
  end

  def supplier_product
    return nil if own? 
    @supplier_product ||= supplier_products.by_node_id(supplier.node.id).first

    #automatically create a product for this dummy supplier
    if dummy? and not @supplier_product and not session
      @supplier_product = DistributionPluginProduct.new(:node => supplier.node, :supplier => supplier)
      from_products << @supplier_product
    end

    @supplier_product
  end
  def supplier_product=(value)
    raise "Cannot set supplier product for own product" if own? 
    raise 'Cannot set product details of a non dummy supplier' unless supplier.dummy?
    supplier_product.update_attributes! value
  end
  #used for a new_record? from a supplier product
  def supplier_product_id
    return nil if own? 
    supplier_product.id if supplier_product
  end
  def supplier_product_id=(id)
    raise "Cannot set supplier product for own product" if own? 
    distribute_from DistributionPluginProduct.find(id) unless id.blank?
  end

  def distribute_from(product)
    s = node.suppliers.from_node(product.node).first
    raise "Supplier not found" if s.blank?

    self.attributes = product.attributes.merge(:supplier_id => s.id)
    self.supplier = s
    from_products << product unless from_products.include? product
    @supplier_product = product
  end

  def price_without_margins
    self['price']
  end
  def price
    price_with_margins = price_without_margins
    return price_with_margins if price_with_margins.blank?

    price_with_margins += (margin_percentage/100)*price_with_margins if margin_percentage
    price_with_margins += margin_fixed if margin_fixed

    price_with_margins
  end

  def unit
    self['unit'] || Unit.new(:singular => _('unit'), :plural => _('units'))
  end

  def archive
    #self.sources_to_products.each { |s| s.destroy }
    self.update_attributes! :archived => true
  end

  alias_method :destroy!, :destroy
  def destroy
    raise "Products shouldn't be destroyed for the sake of the history!"
  end

  protected

  def supplier_change
    errors.add :supplier_id, "supplier can't change" if supplier_id_changed? and not new_record?
  end

end

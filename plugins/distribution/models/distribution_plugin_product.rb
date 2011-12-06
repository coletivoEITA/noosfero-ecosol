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

  # one for organization and the other for typing
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

  # must be overriden on subclasses
  def supplier_products
    []
  end
  def supplier_product
    supplier_products.by_node_id(supplier.node.id).first
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
  validate :supplier_change

  extend ActsAsHavingSettings::DefaultItem::ClassMethods
  acts_as_having_settings :field => :settings

  DEFAULT_ATTRIBUTES = [:name, :description, :margin_percentage, :margin_fixed,
    :price, :stored, :unit_id, :minimum_selleable, :unit_detail]

  settings_default_item :name, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :description, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :margin_percentage, :type => :boolean, :default => true, :delegate_to => :node
  settings_default_item :margin_fixed, :type => :boolean, :default => true, :delegate_to => :node
  settings_default_item :price, :type => :boolean, :default => true, :delegate_to => :from_product
  settings_default_item :stored, :type => :boolean, :default => true, :delegate_to => :from_product
  default_item :unit_id, :if => :default_price, :delegate_to => :from_product
  default_item :minimum_selleable, :if => :default_price, :delegate_to => :from_product
  default_item :unit_detail, :if => :default_price, :delegate_to => :from_product

  def dummy?
    supplier ? supplier.dummy? : false
  end

  def own?
    supplier ? supplier.node == node : false
  end

  def from_product
    from_products.first
  end

  def unit
    self['unit'] || Unit.new(:singular => _('unit'), :plural => _('units'))
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

  def supplier_change
    errors.add :supplier_id, "Supplier can't change" if supplier_id_changed? and not new_record?
  end

end

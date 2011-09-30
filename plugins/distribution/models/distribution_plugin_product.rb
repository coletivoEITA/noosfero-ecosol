class DistributionPluginProduct < ActiveRecord::Base

  default_scope :conditions => {:archived => false}

  belongs_to :node, :class_name => 'DistributionPluginNode'
  named_scope :by_node, lambda { |n| { :conditions => {:node_id => n.id} } }
  named_scope :by_node_id, lambda { |id| { :conditions => {:node_id => id} } }

  #optional fields
  belongs_to :session, :class_name => 'DistributionPluginSession'
  belongs_to :product
  belongs_to :unit
  belongs_to :supplier, :class_name => 'DistributionPluginNode'

  has_one :product_category, :through => :product

  named_scope :distributed, :conditions => ['distribution_plugin_products.session_id is null']
  named_scope :in_session, :conditions => ['distribution_plugin_products.session_id is not null']
  named_scope :for_session, lambda { |session| { :conditions => {:session_id => session.id} } }
  named_scope :from_supplier, lambda { |supplier| { :conditions => {:supplier_id => supplier.id} } }

  named_scope :owned, :conditions => ['distribution_plugin_products.supplier_id is null']
  named_scope :with_supplier, :conditions => ['distribution_plugin_products.supplier_id is not null']
  named_scope :active, :conditions => {:active => true}
  named_scope :inactive, :conditions => {:active => false}
  named_scope :archived, :conditions => {:archived => true}
  named_scope :unarchived, :conditions => {:archived => false}

  has_many :ordered_products, :class_name => 'DistributionPluginOrderedProduct', :foreign_key => 'session_product_id', :dependent => :destroy

  has_many :sources_from_products, :class_name => 'DistributionPluginSourceProduct', :foreign_key => 'to_product_id', :dependent => :destroy
  has_many :sources_to_products, :class_name => 'DistributionPluginSourceProduct', :foreign_key => 'from_product_id', :dependent => :destroy

  has_many :to_products, :through => :sources_to_products
  has_many :from_products, :through => :sources_from_products
  has_many :to_nodes, :through => :to_products, :source => :node
  has_many :from_nodes, :through => :from_products, :source => :node

  validates_presence_of :node
  validates_presence_of :name
  validates_numericality_of :price, :allow_nil => true
  validates_numericality_of :minimum_selleable, :allow_nil => true
  validates_numericality_of :selleable_factor, :allow_nil => true
  validates_numericality_of :margin_percentage, :allow_nil => true
  validates_numericality_of :margin_fixed, :allow_nil => true
  validate :self_supply

  extend ActsAsHavingSettings::DefaultItem::ClassMethods
  acts_as_having_settings :field => :settings
  settings_default_item :name, :type => :boolean, :default => true, :delegate_to => :supplier_product
  settings_default_item :description, :type => :boolean, :default => true, :delegate_to => :supplier_product
  settings_default_item :margin_percentage, :type => :boolean, :default => true, :delegate_to => :supplier_product
  settings_default_item :price, :type => :boolean, :default => true, :delegate_to => :supplier_product
  default_item :unit_id, :if => :default_price, :delegate_to => :supplier_product
  default_item :minimum_selleable, :if => :default_price, :delegate_to => :supplier_product
  default_item :selleable_factor, :if => :default_price, :delegate_to => :supplier_product

  def dummy?
    supplier.dummy?
  end

  def supplier_product
    @supplier_product ||= from_products.by_node_id(supplier_id).first
  end
  def supplier_product=(value)
    raise 'Cannot set product details of a non dummy supplier' unless supplier.dummy?
    supplier_product.update_attributes! value
  end

  #used for a new_record? from a supplier product
  def from_product=(product)
    from_products << product
    @supplier_product = product
  end

  def apply_distribution
    if margin_percentage
      price += (margin_percentage/100)*price
    elsif node.margin_percentage
      price += (node.margin_percentage/100)*price
    end
    if margin_fixed
      price += margin_fixed
    elsif node.margin_fixed
      price += node.margin_fixed
    end
  end

  def unit
    self['unit'] || Unit.first
  end

  def total_quantity_asked
    @total_quantity_asked
  end
  def total_quantity_asked=(value)
    @total_quantity_asked = value
  end

  def archive
    self.update_attributes! :archived => true
  end

  alias_method :destroy!, :destroy
  def destroy
    raise "Products shouldn't be destroyed!"
  end

  protected

  def self_supply
    errors.add :supplier_id, "can't have a product supplied by yourself (supplier_id can't be equal to node_id)" if supplier_id == node_id
  end

end

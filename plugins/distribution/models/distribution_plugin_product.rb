class DistributionPluginProduct < ActiveRecord::Base

  default_scope :conditions => {:archived => false}

  belongs_to :node, :class_name => 'DistributionPluginNode', :foreign_key => 'node_id'

  #optional
  belongs_to :session, :class_name => 'DistributionPluginSession'
  belongs_to :product
  belongs_to :unit
  belongs_to :supplier, :class_name => 'DistributionPluginNode'

  has_one :product_category, :through => :product

  named_scope :distributed, :conditions => ['distribution_plugin_products.session_id is null']
  named_scope :in_session, :conditions => ['distribution_plugin_products.session_id is not null']
  named_scope :for_session, lambda { |session| { :conditions => {:session_id => session.id} } }

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
  has_many :to_suppliers, :through => :to_products, :source => :node
  has_many :from_products, :through => :sources_from_products
  has_many :from_suppliers, :through => :from_products, :source => :node

  validates_presence_of :node
  validates_presence_of :name
  validates_numericality_of :margin_percentage, :allow_nil => true
  validates_numericality_of :margin_fixed, :allow_nil => true

  def dummy?
    supplier.dummy?
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

  def destroy
    raise "Products shouldn't be destroyed!"
  end

end

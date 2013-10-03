class SuppliersPlugin::SourceProduct < Noosfero::Plugin::ActiveRecord

  default_scope :include => [:from_product, :to_product]

  belongs_to :from_product, :class_name => 'Product'
  belongs_to :to_product, :class_name => 'Product'
  belongs_to :supplier, :class_name => 'SuppliersPlugin::Supplier'

  has_many :sources_from_products, :through => :from_product
  has_many :sources_to_products, :through => :to_product

  has_one :supplier_profile, :through => :supplier, :source => :profile

  before_validation :find_supplier

  validates_presence_of :from_product
  validates_presence_of :to_product
  validates_presence_of :supplier
  validates_numericality_of :quantity, :allow_nil => true

  protected

  def find_supplier
    self.supplier = SuppliersPlugin::Supplier.first :conditions => {:profile_id => self.from_product.profile_id, :consumer_id => self.to_product.profile_id}
  end

end

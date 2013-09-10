class SuppliersPlugin::SourceProduct < Noosfero::Plugin::ActiveRecord

  default_scope :include => [:from_product, :to_product]

  belongs_to :from_product, :class_name => 'Product'
  belongs_to :to_product, :class_name => 'Product'

  has_one :supplier, :class_name => 'SuppliersPlugin::Supplier'
  has_one :supplier_profile, :through => :supplier, :source => :profile

  validates_presence_of :to_product
  validates_associated :from_product
  validates_associated :to_product
  validates_numericality_of :quantity, :allow_nil => true

  alias_method :destroy!, :destroy
  def destroy
    to_product.destroy! if to_product
    from_product.destroy! if from_product
    destroy!
  end

end

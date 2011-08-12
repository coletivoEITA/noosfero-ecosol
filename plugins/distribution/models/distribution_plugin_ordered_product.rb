class DistributionPluginOrderedProduct < ActiveRecord::Base
  belongs_to :order, :class_name => 'DistributionPluginOrder'
  belongs_to :session_product, :class_name => 'DistributionPluginSessionProduct'

  validates_presence_of :order
  validates_presence_of :session_product

  validates_numericality_of :quantity_asked, :allow_nil => true
  validates_numericality_of :quantity_allocated, :allow_nil => true
  validates_numericality_of :quantity_payed, :allow_nil => true

  has_one :supplier, :through => :order
  has_one :consumer, :through => :order
  def supplier
    self.order.supplier
  end
  def consumer
    self.order.consumer
  end
  has_one :product, :through => :session_product
  def product
    self.session_product.product
  end

end

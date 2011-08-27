class DistributionPluginSessionProduct < ActiveRecord::Base
  belongs_to :product, :class_name => 'DistributionPluginProduct'
  belongs_to :session, :class_name => 'DistributionPluginSession'
  has_many :ordered_products, :class_name => 'DistributionPluginOrderedProduct', :foreign_key => 'session_product_id', :dependent => :destroy

  validates_presence_of :product
  validates_numericality_of :quantity_available, :allow_nil => true
  validates_numericality_of :price, :allow_nil => true
end

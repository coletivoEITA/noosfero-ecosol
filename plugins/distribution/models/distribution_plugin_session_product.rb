class DistributionPluginSessionProduct < ActiveRecord::Base
  has_many :ordered_products, :class_name => 'DistributionPluginOrderedProduct'
  belongs_to :product, :class_name => 'DistributionPluginProduct'
  belongs_to :session, :class_name => 'DistributionPluginSession'

  validates_presence_of :product
  validates_numericality_of :quantity_available, :allow_nil => true
  validates_numericality_of :price, :allow_nil => true
end

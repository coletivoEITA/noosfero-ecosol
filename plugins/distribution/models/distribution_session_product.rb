class DistributionSessionProduct < ActiveRecord::Base
  has_many :ordered_products, :class_name => 'DistributionOrderedProduct'
  belongs_to :product, :class_name => 'DistributionProduct'
  belongs_to :session, :class_name => 'DistributionSession'
end

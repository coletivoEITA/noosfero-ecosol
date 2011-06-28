class DistributionPluginSessionProduct < ActiveRecord::Base
  has_many :ordered_products, :class_name => 'DistributionPluginOrderedProduct'
  belongs_to :product, :class_name => 'DistributionPluginProduct'
  belongs_to :session, :class_name => 'DistributionPluginOrderSession'
end

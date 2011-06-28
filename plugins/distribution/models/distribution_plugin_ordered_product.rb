class DistributionPluginOrderedProduct < ActiveRecord::Base
  belongs_to :order, :class_name => 'DistributionPluginOrder'
  belongs_to :session_product, :class_name => 'DistributionPluginSessionProduct'

end

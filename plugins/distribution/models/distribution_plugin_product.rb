class DistributionPluginProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :unit
  belongs_to :node, :class_name => 'DistributionPluginNode', :foreign_key => 'node_id'
  has_many   :sources, :class_name => 'DistributionPluginSourceProduct', :foreign_key => 'to_product_id'
  has_many   :used_by, :class_name => 'DistributionPluginSourceProduct', :foreign_key => 'from_product_id'
  has_many   :session_products, :class_name => 'DistributionPluginSessionProduct', :foreign_key => 'product_id'

  validates_presence_of :product
  validates_presence_of :node

end

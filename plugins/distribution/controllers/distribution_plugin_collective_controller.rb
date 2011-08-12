class DistributionPluginCollectiveController < DistributionPluginMyprofileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  no_design_blocks

  def index
    @node = DistributionPluginNode.find_by_profile_id(profile.id)
  end

  def our_products
    node = DistributionPluginNode.find_by_profile_id profile.id
    @products = DistributionPluginProduct.find_all_by_node_id(node.id)
    @suppliers = node.suppliers
    @product_categories = ProductCategory.find(:all)
  end
end

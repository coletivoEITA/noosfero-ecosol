class DistributionPluginSupplierController < MyProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
    @node = DistributionPluginNode.find_by_profile_id(profile.id)
  end

end

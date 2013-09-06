class NetworksPluginMyprofileController < MyProfileController

  def index
    @networks = NetworksPlugin::Network.all
  end

  def show_structure
    @network = profile
    @relations = SubOrganizationsPlugin::Relation.all :conditions => ["parent_id = ?", @network.id]
  end

end

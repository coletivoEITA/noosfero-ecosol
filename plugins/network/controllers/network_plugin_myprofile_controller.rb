class NetworkPluginMyprofileController < MyProfileController
  
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index 
    @networks = NetworkPlugin::Network.all
  end

  def show_structure
    @network = NetworkPlugin::Network.find(params[:id])
    @relations = SubOrganizationsPlugin::Relation.all(:conditions => 
      ["parent_id = ?", @network.id])
  end
end

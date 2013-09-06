class NetworksPluginNetworkController < MyProfileController

  def index
    redirect_to :show_structure
  end

  def show_structure
    @network = profile

    relations = SubOrganizationsPlugin::Relation.all :conditions => ["parent_id = ?", @network.id], :include => [:child]
    suppliers = SuppliersPlugin::Supplier.of_consumer_id(profile.id).all :include => :profile
    @profiles = relations.collect(&:child) + suppliers.collect(&:profile)
  end

  def enterprise_search
    @network = profile

    if params[:query]
      @enterprises = find_by_contents(:enterprises, environment.enterprises, params[:query])[:results]
    end
  end

  protected

end

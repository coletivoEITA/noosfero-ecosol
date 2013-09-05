class NetworksPluginAdminController < AdminController

  def index
    @node = Profile.find(params[:id])
    @network = SubOrganizationsPlugin::Relation.find_by_child_id(@node).parent
  end

  def edit
    @node = Profile.find(params[:id])
  end

  def update
    @node = Profile.find(params[:id])
    if @node.is_a? Enterprise
      @node.description = params[:enterprise][:description]
    else
      @node.description = params[:networks_plugin_node][:description]
    end

    if @node.save
      redirect_to :action => 'index', :id => @node.id
    else
      redirect_to :action => 'edit', :id => @node.id
    end
  end

  def profile_search
    @net = NetworksPlugin::Network.find(:first, params[:net_id])

    if params[:query]
      @profiles = Profile.find(:all, :conditions =>
        ["name ILIKE ?", "%#{params[:query]}%"])

      if @profiles.blank?
        flash[:error] = "Nenhum empreendimento foi encontrado. Por favor revise
          o texto da busca, conferindo espaços, acentos gráficos etc."

        redirect_to :action => 'profile_search'
      end
    end
  end

  def add_to_network
    net = NetworksPlugin::Network.find params[:net_id]
    profile = Profile.find params[:profile_id]
    relation = SubOrganizationsPlugin::Relation.new :parent_id => net.id, :child_id => profile.id

    if relation.save
      flash[:notice] = "Entidade adicionada com sucesso a rede."
      redirect_to :controller => :networks_plugin_myprofile, :profile => net.identifier, :action => :show_structure
    else
      flash[:error] = "Não foi possível adicionar esse nó a rede. Verifique se
        esta entidade já não está associado a esta rede."
      redirect_to :back
    end
  end

  def destroy
    relation = SubOrganizationsPlugin::Relation.find_by_id params[:id]

    if relation
      @net = relation.parent
      if relation.destroy
        flash[:notice] = "Entidade removida da rede com sucesso."
      else
        flash[:error] = "Entidade não pode ser removida da rede."
      end
    else
      #TODO: raise an exception
      flash[:error] = "Entidade não existe nesta rede."
    end

    redirect_to "/myprofile/#{@net.identifier}/plugin/network/show_structure/#{@net.id}"
  end

  protected

end

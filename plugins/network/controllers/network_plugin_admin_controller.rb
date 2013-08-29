class NetworkPluginAdminController < AdminController
  
  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  

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
      @node.description = params[:network_plugin_node][:description]
    end

    if @node.save
      redirect_to :action => 'index', :id => @node.id
    else
      redirect_to :action => 'edit', :id => @node.id
    end
  end

  def profile_search
    @net = NetworkPlugin::Network.find(:first, params[:net_id])

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
    net = NetworkPlugin::Network.find(:first, params[:net_id])
    profile = Profile.find_by_id params[:profile_id]
    relation = SubOrganizationsPlugin::Relation.new

    if !relation_exists?(net.id, profile.id)
      relation.parent = net
      relation.child = profile

      if relation.save
        flash[:notice] = "Entidade adicionada com sucesso a rede."
        redirect_to "/myprofile/#{net.identifier}/plugin/network/show_structure/#{net.id}"
      end
    else
      flash[:error] = "Não foi possível adicionar esse nó a rede. Verifique se 
        esta entidade já não está associado a esta rede."
      redirect_to :back
    end
  end

  def destroy
    relation = SubOrganizationsPlugin::Relation.find(:first,
      :conditions => ["id = ?", params[:id]] )
    
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

private
  
  def relation_exists?(parent_id, child_id)
    relation = SubOrganizationsPlugin::Relation.find(:first, :conditions => 
      ["parent_id = ? AND child_id = ?", parent_id, child_id])
    
    if relation.blank?
      return nil
    end

    relation
  end

end

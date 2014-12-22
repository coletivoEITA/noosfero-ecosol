class PluginsController < AdminController
  protect 'edit_environment_features', :environment

  def index
    @active_plugins = Noosfero::Plugin.all.map {|plugin_name| plugin_name.constantize }.compact
  end

  post_only :update
  def update
    enabled_plugins = params[:environment][:enabled_plugins].to_a
    enabled_plugins.delete ''
    enabled_plugins += Noosfero::Plugin::DependencyCalc.deps_unmet(*enabled_plugins).map{ |p| "#{p.camelize}Plugin" }

    if @environment.update_attribute :enabled_plugins, enabled_plugins
      session[:notice] = _('Plugins updated successfully.')
    else
      session[:error] = _('Plugins were not updated successfully.')
    end
    redirect_to :action => 'index'
  end

end

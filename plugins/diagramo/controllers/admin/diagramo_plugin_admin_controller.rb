class DiagramoPluginAdminController < AdminController

  def index
    # FIXME: remove request.post? on rails3
    if request.put? or request.post?
      environment.diagramo_settings = params[:environment][:diagramo_settings]
      environment.save!
    end
  end

  protected

end

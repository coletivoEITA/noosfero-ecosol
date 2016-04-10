class TeamsPlugin::TeamsController < MyProfileController

  before_filter :load_context

  def index
    render :index, locals: {context: @context}
  end

  def create
    @team = @context.teams.create! context: @context
    render json: @team
  end

  def update
    @team = @context.teams.find params[:id]
    attrs = params[:team].except :id, :members
    @team.update! attrs
    render nothing: true
  end

  def destroy
    @team = @context.teams.find params[:id]
    @team.destroy
    render nothing: true
  end

  protected

  def load_context
    @context = params[:context][:type].constantize.find params[:context][:id]
  end

end

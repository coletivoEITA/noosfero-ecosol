class TeamsPlugin::MembersController < MyProfileController

  before_filter :load_context

  def search
    @team = @context.teams.find params[:team_id]
    @query = params[:query]
    @members_ids = @team.members.map(&:profile_id)
    @people = environment.people.is_public.limit(10).order('name ASC').
      where('name ILIKE ? OR name ILIKE ? OR identifier LIKE ?', "#{@query}%", "% #{@query}%", "#{@query}%").
      where.not(id: @members_ids)

    render json: @people.map{ |p| TeamsPlugin::MemberSerializer.new(p).attributes }
  end

  def add
    @team = @context.teams.find params[:team_id]
    @member = @team.members.create! profile_id: params[:id]

    render json: TeamsPlugin::MemberSerializer.new(@member).attributes
  end

  def destroy
    @team = @context.teams.find params[:team_id]
    @member = @team.members.find params[:id]
    @member.destroy

    render nothing: true
  end

  protected

  def load_context
    @context = params[:context][:type].constantize.find params[:context][:id]
  end

end

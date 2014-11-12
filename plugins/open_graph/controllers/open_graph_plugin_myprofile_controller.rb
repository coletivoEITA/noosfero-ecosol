class OpenGraphPluginMyprofileController < MyProfileController

  def enterprise_search
    profile_search environment.enterprises
  end
  def community_search
    profile_search environment.communities
  end
  def friend_search
    profile_search profile.friends
  end

  protected

  def profile_search scope
    @query = params[:query]
    @profiles = scope.
      where(['name ILIKE ? OR name ILIKE ? OR identifier LIKE ?', "#{@query}%", "% #{@query}%", "#{@query}%"])
    render 'profile_search'
  end

end


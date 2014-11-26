class OpenGraphPluginMyprofileController < MyProfileController

  protect 'edit_profile', :profile

  def enterprise_search
    exclude_ids = profile.open_graph_enterprise_tracks.map(&:object_data_id)
    profile_search environment.enterprises, exclude_ids
  end
  def community_search
    exclude_ids = profile.open_graph_community_tracks.map(&:object_data_id)
    profile_search environment.communities, exclude_ids
  end
  def friend_search
    exclude_ids = profile.open_graph_friend_tracks.map(&:object_data_id)
    profile_search profile.friends, exclude_ids
  end

  def track_config
    profile.update_attributes! params[:profile_data]
    render partial: 'track_form'
  end

  protected

  def profile_search scope, exclude_ids = []
    @query = params[:query]
    @profiles = scope.
      where(['name ILIKE ? OR name ILIKE ? OR identifier LIKE ?', "#{@query}%", "% #{@query}%", "#{@query}%"]).
      where(['profiles.id NOT IN (?)', exclude_ids])
    render 'profile_search'
  end

end


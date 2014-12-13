class OpenGraphPluginMyprofileController < MyProfileController

  protect 'edit_profile', :profile

  def enterprise_search
    scope = environment.enterprises.enabled.public
    exclude_ids = profile.open_graph_enterprise_tracks.map(&:object_data_id)
    profile_search scope, exclude_ids
  end
  def community_search
    scope = environment.communities.public
    exclude_ids = profile.open_graph_community_tracks.map(&:object_data_id)
    profile_search scope, exclude_ids
  end
  def friend_search
    scope = profile.friends
    exclude_ids = profile.open_graph_friend_tracks.map(&:object_data_id)
    profile_search scope, exclude_ids
  end

  def track_config
    profile.update_attributes! params[:profile_data]
    render partial: 'track_form'
  end

  protected

  def profile_search scope, exclude_ids = []
    @query = params[:query]
    @profiles = scope.limit(10).order('name ASC').
      where(['name ILIKE ? OR name ILIKE ? OR identifier LIKE ?', "#{@query}%", "% #{@query}%", "#{@query}%"])
    @profiles = @profiles.where(['profiles.id NOT IN (?)', exclude_ids]) if exclude_ids.present?
    render partial: 'profile_search', locals: {profiles: @profiles}
  end

end


module UrlHelper

  def url_for options = {}
    return super unless options.is_a? Hash

    # @domain.owner_type check avoids an early fetch of @domain.profile
    if @domain and @domain.owner_type != 'Environment' and @domain.profile and @domain.profile.identifier == options[:profile]
      # remove profile parameter for better URLs in custom domains
      options.delete :profile
    end

    super
  end

end

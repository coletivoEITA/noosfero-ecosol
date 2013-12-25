class OauthPluginApiController < PublicController

  def userinfo
    @scope = OmniAuth::Strategies::Noosfero::DefaultScope.split ','
    @token = Songkick::OAuth2::Provider.access_token :implicit, @scope, request.env
    @user = @token.owner

    if @token.valid? and @user.activated?
      json = JSON.unparse :userinfo => {:email => @user.email, :identifier => @user.login, :name => @user.person.name}
    else
      json = JSON.unparse 'error' => 'Invalid token'
    end

    render :json => json
    response.header.merge! @token.response_headers
    response.status = @token.response_status
  end

  protected

end

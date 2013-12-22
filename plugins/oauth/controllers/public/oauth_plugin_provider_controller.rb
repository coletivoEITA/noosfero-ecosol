class OauthPluginProviderController < PublicController

  no_design_blocks

  def authorize
    @auth = Songkick::OAuth2::Provider.parse current_user, request.env

    if @auth.redirect?
      redirect_to @auth.redirect_uri, :status => @auth.response_status
      return
    end

    # save for 'allow' action
    session[:oauth2_app_auth] = @auth.params

    if body = @auth.response_body
      render :text => body
    elsif @auth.valid?
      render :action => :authorize
    else
      render :template => 'error'
    end

    response.header.merge! @auth.response_headers
    response.status = @auth.response_status
  end

  def allow
    @auth = Songkick::OAuth2::Provider::Authorization.new current_user, session.delete(:oauth2_app_auth)
    return render_not_found if @auth.blank?

    @auth.grant_access! :duration => 1.hours
    redirect_to @auth.redirect_uri, :status => @auth.response_status
  end

  def token
    @exchange = Songkick::OAuth2::Provider::Exchange.new :implicit, params
    render :json => @exchange.response_body
    response.header.merge! @exchange.response_headers
    response.status = @exchange.response_status
  end

  protected

end

class OauthPluginAuthController < PublicController

  no_design_blocks

  def callback
    @provider = environment.oauth_providers.find_by_identifier params[:id]
    @strategy = request.env['omniauth.strategy']
    @auth = request.env['omniauth.auth']

    if params[:error]
      raise @error
      return
    end

    @email = @auth.info.email
    @user = environment.users.find_by_email @email
    if @user
      self.current_user = @user
      redirect_to request.env['omniauth.origin'] || {:controller => :home}
    else
      session[:skip_user_activation_for_email] = @email

      user_info = OauthPlugin::UserInfo.new @strategy.options.name, @auth
      redirect_to user_info.signup_params.merge(:controller => :account, :action => :signup)
    end
  end

  def failure
    @strategy = params[:strategy]
    @message_key = params[:message]
  end

  protected

end

module AuthenticatedSystem

  protected

    def self.included base
      # See impl. from http://stackoverflow.com/a/2513456/670229
      base.around_filter do |&block|
        begin
          User.current = current_user
          block.call
        ensure
          # to address the thread variable leak issues in Puma/Thin webserver
          User.current = nil
        end
      end if base.is_a? ActionController::Base

      # Inclusion hook to make #current_user and #logged_in?
      # available as ActionView helper methods.
      base.send :helper_method, :current_user, :logged_in?
    end

    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      current_user != nil
    end

    # Accesses the current user from the session.
    def current_user
      @current_user ||= begin
        id = session[:user]
        user = User.where(id: id).first if id
        user.session = session if user
        User.current = user
        user
      end
    end

    # Store the given user in the session.
    def current_user=(new_user)
      if new_user.nil?
        session.delete(:user)
      else
        session[:user] = new_user.id
        new_user.session = session
        new_user.register_login
      end
      @current_user = User.current = new_user
    end

    # Check if the user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_user.login != "bob"
    #  end
    def authorized?
      true
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      username, passwd = get_auth_data
      if username && passwd
        self.current_user ||= User.authenticate(username, passwd) || nil
      end
      if logged_in? && authorized?
        true
      else
        if params[:require_login_popup]
          render :json => { :require_login_popup => true }
        else
          access_denied
        end
      end
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          if request.xhr?
            render :text => _('Access denied'), :status => 401
          else
            store_location
            redirect_to :controller => '/account', :action => 'login'
          end
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location(location = request.url)
      session[:return_to] = location
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      uri = session.delete(:return_to) || default
      # break cache after login
      if uri.is_a? String
        uri = URI.parse uri
        new_query_ar = URI.decode_www_form(uri.query || '') << ["_", Time.now.to_i.to_s]
        uri.query = URI.encode_www_form new_query_ar
        uri = uri.to_s
      elsif uri.is_a? Hash
        uri.merge! _: Time.now.to_i
      end

      redirect_to uri
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return if cookies[:auth_token].blank? or logged_in?
      user = User.where(remember_token: cookies[:auth_token]).first
      self.current_user = user if user and user.remember_token?
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil]
    end
end

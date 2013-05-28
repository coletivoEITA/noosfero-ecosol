require "#{File.dirname __FILE__}/ext/noosfero"

class SignupWithEnterprisePlugin < Noosfero::Plugin

  def self.plugin_name
    "Signup with Enterprise"
  end

  def self.plugin_description
    _("Signup in two steps linking the user to a new or an existing enterprise.")
  end

  # Code copied from account_controller. FIXME: make that code reusable
  AccountSignup = proc do
    if @plugins.dispatch(:allow_user_registration).include?(false)
      redirect_back_or_default(:controller => 'home')
      session[:notice] = _("This environment doesn't allow user registration.")
    end

    @block_bot = !!session[:may_be_a_bot]
    @invitation_code = params[:invitation_code]
    begin
      @user = User.new(params[:user])
      @user.terms_of_use = environment.terms_of_use
      @user.environment = environment
      @terms_of_use = environment.terms_of_use
      @user.person_data = params[:profile_data]
      @person = Person.new(params[:profile_data])
      @person.environment = @user.environment

      params[:enterprise_data] ||= {}
      @enterprise = Enterprise.new params[:enterprise_data].merge(:environment => environment)

      if request.post?
        if may_be_a_bot
          set_signup_start_time_for_now
          @block_bot = true
          session[:may_be_a_bot] = true
        else
          if session[:may_be_a_bot]
            return false unless verify_recaptcha :model=>@user, :message=>_('Captcha (the human test)')
          end

          ::ActiveRecord::Base.transaction do
            @user.signup!
            owner_role = Role.find_by_name('owner')
            @user.person.affiliate(@user.person, [owner_role]) if owner_role
            invitation = Task.find_by_code(@invitation_code)
            if invitation
              invitation.update_attributes!({:friend => @user.person})
              invitation.finish
            end
            @person = @user.person

            if params[:register_enterprise][:box] == "1"
              @enterprise.identifier = Noosfero.convert_to_identifier @enterprise.name
              @enterprise.save!
              @enterprise.add_admin @person
            end
          end

          if @user.activated?
            self.current_user = @user
            redirect_to :controller => :profile_editor, :profile => @enterprise.identifier
            return
          else
            @register_pending = true
          end
        end
      end
    rescue ::ActiveRecord::RecordInvalid
      @person.valid?
      @person.errors.delete(:identifier)
      @person.errors.delete(:user_id)
    end
    clear_signup_start_time

    render :action => 'signup'
  end

  def account_controller_filters
    [
      {:type => 'before_filter',
       :method_name => 'signup_with_enteprise_plugin',
       :options => {:only => :signup},
       :block => AccountSignup,
      },
    ]
  end

  def stylesheet?
    true
  end

end

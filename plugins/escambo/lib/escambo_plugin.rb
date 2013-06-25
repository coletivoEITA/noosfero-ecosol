require 'cms_learning_plugin'
require 'currency_plugin'
require 'evaluation_plugin'
require 'exchange_plugin'
require 'sniffer_plugin'
require 'solr_plugin'

require_dependency "#{File.dirname __FILE__}/ext/noosfero"

class EscamboPlugin < Noosfero::Plugin

  def self.plugin_name
    "EscamboPlugin"
  end

  def self.plugin_description
    _("ESCAMBO network integration plugin")
  end

  def stylesheet?
    true
  end

  def js_files
    ['escambo.js']
  end

  SearchLimit = 20
  SearchDataLoad = proc do
    options = {:limit => SearchLimit, :conditions => ['created_at IS NOT NULL'], :order => 'created_at DESC'}
    @interests = SnifferPluginOpportunity.all options
    @products = Product.all options
    @knowledges = CmsLearningPluginLearning.all options
  end
  SearchDataMix = proc do
    @results = @interests + @products + @knowledges
    @results = @results.sort_by{ |r| r.created_at }
    @results = @results.last SearchLimit
  end
  SearchIndexFilter = proc do
    if @query.empty?
      instance_eval &SearchDataLoad
    else
      @interests = find_by_contents(:sniffer_plugin_opportunities, SnifferPluginOpportunity, @query, paginate_options).results
      @products = find_by_contents(:products, Product, @query, paginate_options)[:results].results
      @knowledges = find_by_contents(:cms_learning_plugin_learnings, CmsLearningPluginLearning, @query, paginate_options)[:results].results
    end
    instance_eval &SearchDataMix

    # overwrite controller action
    render :action => :index
  end
  def search_controller_filters
    [
      {:type => 'before_filter', :method_name => 'escambo_search_index',
       :options => {:only => :index}, :block => SearchIndexFilter},
    ]
  end

  HomeIndexFilter = proc do
    offset = environment.enterprises.count - SearchLimit
    offset = 0 if offset < 0
    @enterprises = environment.enterprises.visible.all :offset => rand(offset), :limit => SearchLimit

    instance_eval &SearchDataLoad
    instance_eval &SearchDataMix

    # overwrite controller action
    render :action => :index
  end
  def home_controller_filters
    [
      {:type => 'before_filter', :method_name => 'escambo_home_index',
       :options => {:only => :index}, :block => HomeIndexFilter},
    ]
  end

  ProfileIndexFilter = proc do
    return unless profile.enterprise?

    render :action => 'index'
  end
  def profile_controller_filters
    [
      {:type => 'before_filter', :method_name => 'escambo_profile_index',
       :options => {:only => :index}, :block => ProfileIndexFilter},
    ]
  end

  CatalogIndexFilter = proc do
    redirect_to :controller => :profile, :action => :products
  end
  def catalog_controller_filters
    [
      {:type => 'before_filter', :method_name => 'escambo_catalog_index',
       :options => {:only => :index}, :block => CatalogIndexFilter},
    ]
  end

  def profile_image_link profile, size=:portrait, tag='li', extra_info = nil
    return unless profile.enterprise?
    lambda do
      render :file => 'escambo_plugin_shared/profile_image_link', :locals => {:profile => profile, :size => size}
    end
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
>>>>>>> d294265ab1136f62792501c06b78e1b4bd7e516f
    end
    clear_signup_start_time

    # overwrite controller action
    render :action => 'signup'
  end
  def account_controller_filters
    [
      {:type => 'before_filter', :method_name => 'escambo_signup_with_enteprise',
       :options => {:only => :signup}, :block => AccountSignup},
    ]
  end

end

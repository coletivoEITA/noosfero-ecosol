require_dependency 'solr_plugin'
require_dependency 'solr_plugin/search_helper'

SolrPlugin::Base.send :remove_method, :search_pre_contents
SolrPlugin::Base.send :remove_method, :search_post_contents

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
    ['escambo.js'].map{ |j| "javascripts/#{j}" }
  end

  def profile_image_link profile, size=:portrait, tag='li', extra_info = nil
    return unless profile.enterprise?
    lambda do
      render file: 'escambo_plugin_shared/profile_image_link', locals: {profile: profile, size: size}
    end
  end

  SearchLimit = 20
  SearchDataLoad = proc do
    solr_options = {}
    paginate_options ||= {limit: SearchLimit}
    @query ||= ''
    @geosearch = true if @active_organization and @active_organization.lat and @active_organization.lng

    if @geosearch
      solr_options.merge! alternate_query: "{!boost b=recip(geodist(),#{"%e" % (1.to_f/SolrPlugin::SearchHelper::DistBoost)},1,1)}",
        latitude: @active_organization.lat, longitude: @active_organization.lng
    end
    if @active_organization
      solr_options.merge! filter_queries: ["!profile_id_i:#{@active_organization.id}"]
    end

    @interests = SnifferPlugin::Opportunity.find_by_contents(@query, paginate_options, solr_options)[:results].results
    @products = Product.find_by_contents(@query, paginate_options, solr_options)[:results].results
    @knowledges = CmsLearningPlugin::Learning.find_by_contents(@query, paginate_options, solr_options)[:results].results

    @results = @interests + @products + @knowledges
    @results = @results.sort_by{ rand } unless @geosearch
    @results = @results.last SearchLimit
  end
  SearchDataMix = proc do
  end
  SearchIndexFilter = proc do
    instance_exec &SearchDataLoad

    # overwrite controller action
    render action: :index
  end
  def search_controller_filters
    [
      {type: 'before_filter', method_name: 'escambo_search_index',
       options: {only: :index}, block: SearchIndexFilter},
    ]
  end

  HomeIndexFilter = proc do
    offset = environment.enterprises.count - SearchLimit
    offset = 0 if offset < 0
    @enterprises = environment.enterprises.visible.all offset: rand(offset), limit: SearchLimit
    @enterprises = @enterprises.sort_by{ rand }

    instance_exec &SearchDataLoad

    # overwrite controller action
    render action: :index
  end
  def home_controller_filters
    [
      {type: 'before_filter', method_name: 'escambo_home_index',
       options: {only: :index}, block: HomeIndexFilter},
    ]
  end

  ProfileEditorIndexFilter = proc do
    redirect_to profile.url
  end
  def profile_editor_controller_filters
    [
      {type: 'before_filter', method_name: 'escambo_profile_editor_index',
       options: {only: :index}, block: ProfileEditorIndexFilter},
    ]
  end

  ProfileIndexFilter = proc do
    if profile.enterprise?
      render action: 'index'
    else
      redirect_to controller: 'home'
    end
  end
  def profile_controller_filters
    [
      {type: 'before_filter', method_name: 'escambo_profile_index',
       options: {only: :index}, block: ProfileIndexFilter},
    ]
  end

  CatalogIndexFilter = proc do
    redirect_to controller: :profile, action: :products
  end
  def catalog_controller_filters
    [
      {type: 'before_filter', method_name: 'escambo_catalog_index',
       options: {only: :index}, block: CatalogIndexFilter},
    ]
  end

  # FIXME code copied... try to share
  ContactFilter = proc do
    @contact
    if request.post? && params[:confirm] == 'true'
      @contact = user.build_contact(profile, params[:contact])
      @contact.city = (!params[:city].blank? && City.exists?(params[:city])) ? City.find(params[:city]).name : nil
      @contact.state = (!params[:state].blank? && State.exists?(params[:state])) ? State.find(params[:state]).name : nil
      if @contact.deliver
        session[:notice] = _('Contact successfully sent')
        redirect_to request.referer
      else
        session[:notice] = _('Contact not sent')
      end
    else
      @contact = user.build_contact(profile)
    end
  end
  def contact_controller_filters
    [
      {type: 'before_filter', method_name: 'escambo_contact',
       options: {}, block: ContactFilter},
    ]
  end

  # Code copied from account_controller. FIXME: make that code reusable
  AccountSignup = proc do
    if @plugins.dispatch(:allow_user_registration).include?(false)
      redirect_back_or_default(controller: 'home')
      session[:notice] = _("This environment doesn't allow user registration.")
    end

    #@block_bot = !!session[:may_be_a_bot]
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
      @enterprise = Enterprise.new params[:enterprise_data].merge(environment: environment)

      @selected_enterprise = environment.enterprises.find_by_id params[:enterprise_id]
      @enterprises = []

      if request.post?
        @enterprise = @selected_enterprise unless params[:enterprise_register] == "true"

        ::ActiveRecord::Base.transaction do
          @user.signup!
          owner_role = Role.find_by_name('owner')
          @user.person.affiliate(@user.person, [owner_role]) if owner_role
          invitation = Task.find_by_code(@invitation_code)
          if invitation
            invitation.update_attributes!({friend: @user.person})
            invitation.finish
          end
          @person = @user.person

          if params[:enterprise_register] == "true"
            @enterprise.identifier = @enterprise.name.to_slug
            @enterprise.save!
            @enterprise.add_admin @person
          else
            @enterprise.add_member @person
          end
        end

        @user.activate if session.delete(:skip_user_activation_for_email) == @user.email
        if @user.activated?
          self.current_user = @user
          redirect_to @enterprise.url
        else
          @register_pending = true
        end
      end
    rescue ::ActiveRecord::RecordInvalid
      @person.valid?
      @person.errors.delete(:identifier)
      @person.errors.delete(:user_id)
    end

    # overwrite controller action
    render action: 'signup' unless @performed_render or @performed_redirect
  end
  def account_controller_filters
    [
      {type: 'before_filter', method_name: 'escambo_signup_with_enteprise',
       options: {only: :signup}, block: AccountSignup},
    ]
  end

end

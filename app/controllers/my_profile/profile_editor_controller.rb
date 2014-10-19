class ProfileEditorController < MyProfileController

  protect 'edit_profile', :profile, :except => [:destroy_profile]
  protect 'destroy_profile', :profile, :only => [:destroy_profile]

  def index
    @pending_tasks = Task.to(profile).pending.without_spam.select{|i| user.has_permission?(i.permission, profile)}
  end

  helper :profile

  # edits the profile info (posts back)
  def edit
    @profile_data = profile
    @possible_domains = profile.possible_domains
    if request.post?
      params[:profile_data][:fields_privacy] ||= {} if profile.person? && params[:profile_data].is_a?(Hash)
      Profile.transaction do
      Image.transaction do
        if @profile_data.update_attributes(params[:profile_data])
          redirect_to :action => 'index', :profile => profile.identifier
        else
          profile.identifier = params[:profile] if profile.identifier.blank?
        end
      end
      end
    end
  end

  def enable
    if request.post? && params[:confirmation]
      unless profile.enable user
        session[:notice] = _('%s was not enabled.') % profile.name
      end
      redirect_to :action => :index
    end
  end

  def disable
    if request.post? && params[:confirmation]
      unless profile.update_attribute :enabled, false
        session[:notice] = _('%s was not disabled.') % profile.name
      end
      redirect_to :action => :index
    end
  end

  def update_categories
    @object = profile
    @categories = @toplevel_categories = environment.top_level_categories
    if params[:category_id]
      @current_category = Category.find(params[:category_id])
      @categories = @current_category.children.alphabetical
    end
    render :template => 'shared/update_categories', :locals => { :category => @current_category, :object_name => 'profile_data' }
  end

  def header_footer
    @no_design_blocks = true
    if request.post?
      @profile.update_header_and_footer(params[:custom_header], params[:custom_footer])
      redirect_to :action => 'index'
    else
      @header = boxes_holder.custom_header
      @footer = boxes_holder.custom_footer
    end
  end

  def destroy_profile
    if request.post?
      if @profile.destroy
        session[:notice] = _('The profile was deleted.')
        redirect_to :controller => 'home'
      else
        session[:notice] = _('Could not delete profile')
      end
    end
  end
end

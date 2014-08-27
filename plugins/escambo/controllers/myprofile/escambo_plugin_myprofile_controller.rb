class EscamboPluginMyprofileController < MyProfileController

  def select_active_organization
    load_active_organization params[:profile_id]
  end

  def new_enterprise
    params[:enterprise_data] ||= {}
    @enterprise = Enterprise.new params[:enterprise_data].merge(:environment => environment)
    if request.post?
      @enterprise.identifier = @enterprise.name.to_slug
      if @enterprise.save
        @enterprise.add_admin profile
        redirect_to @enterprise.url
      end
    end
  end

  def add_member
    @roles = environment.roles.where(:key => 'profile_admin')
  end

end

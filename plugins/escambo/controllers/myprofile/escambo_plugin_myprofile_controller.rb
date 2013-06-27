class EscamboPluginMyprofileController < MyProfileController

  def select_active_organization
    load_active_organization params[:profile_id]
  end

  def new_enterprise
    params[:enterprise_data] ||= {}
    @enterprise = Enterprise.new params[:enterprise_data].merge(:environment => environment)
    if request.post?
      @enterprise.identifier = Noosfero.convert_to_identifier @enterprise.name
      @enterprise.save!
      @enterprise.add_admin profile
      redirect_to enterprise.url
    end
  end

end

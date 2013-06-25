class EscamboPluginMyprofileController < MyProfileController

  def select_active_organization
    load_active_organization params[:profile_id]
  end

  def new_enterprise
  end

end

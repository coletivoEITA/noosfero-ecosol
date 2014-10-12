class VolunteersPluginMyprofileController < MyProfileController

  no_design_blocks

  protect 'edit_profile', :profile

  def index

  end

  protected

end

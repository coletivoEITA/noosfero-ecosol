class DistributionPluginMyprofileController < MyProfileController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  no_design_blocks

  def index
  end

end

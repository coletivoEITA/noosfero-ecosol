require "test_helper"

class OpenGraphPlugin::ActivityTrackConfigTest < ActiveSupport::TestCase

  def setup
    @actor = create_user.person

  end

  should "track only selected activities" do

  end

end

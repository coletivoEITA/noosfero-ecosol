require 'test_helper'
require 'open_graph_plugin/myprofile_controller'

# Re-raise errors caught by the controller.
class OpenGraphPlugin::MyprofileController; def rescue_action(e) raise e end; end

class OpenGraphPlugin::MyprofileControllerTest < ActionController::TestCase

  def setup
    @actor = create_user.person

  end

  should "save selected activities" do
    login_as @actor.identifier
    @enterprise = @actor.environment.enterprises.create! name: 'coop'
    @enterprise.fans << @actor

    post :track_config, profile_data: {
      open_graph_settings: {
        activity_track_enabled: "true",
        enterprise_track_enabled: "true",
        community_track_enabled: "false",
      },
      open_graph_activity_track_configs_attributes: {
        0 => {
          id: 1,
          tracker_id: @actor.id,
          object_type: 'blog_post',
        },

      },
      open_graph_enterprise_profiles_ids: [@enterprise.id],
    }

    assert_equal true, @actor.open_graph_settings.activity_track_enabled
    assert_equal true, @actor.open_graph_settings.enterprise_track_enabled
    assert_equal false, @actor.open_graph_settings.community_track_enabled

  end

end

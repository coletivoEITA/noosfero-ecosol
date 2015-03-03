require "test_helper"

class OpenGraphPlugin::PublisherTest < ActiveSupport::TestCase

  def setup
    @actor = create_user.person
    User.current = @actor.user
    @stories = OpenGraphPlugin::Stories::Definitions
    @publisher = OpenGraphPlugin::Stories.publishers.first
    @publisher.stubs(:context).returns(:open_graph)
  end

  should "publish only tracked stuff" do
    @other_actor = create_user.person

    @myenterprise = @actor.environment.enterprises.create! name: 'mycoop', identifier: 'mycoop'
    @myenterprise.add_member @actor
    @enterprise = @actor.environment.enterprises.create! name: 'coop', identifier: 'coop'
    @enterprise.fans << @actor

    @community = @actor.environment.communities.create! name: 'comm', identifier: 'comm', closed: false

    @actor.update_attributes!({
      open_graph_settings: {
        activity_track_enabled: "true",
        enterprise_track_enabled: "true",
        community_track_enabled: "true",
      },
      open_graph_activity_track_configs_attributes: {
        0 => {
          tracker_id: @actor.id,
          object_type: 'blog_post',
        },
        1 => {
          tracker_id: @actor.id,
          object_type: 'gallery_image',
        },
      },
      open_graph_enterprise_profiles_ids: [@enterprise.id],
      open_graph_community_profiles_ids: [@community.id],
    })

    # active
    User.current = @actor.user
    blog = Blog.create! profile: @actor, name: 'blog'
    blog_post = TinyMceArticle.new profile: @actor, parent: blog, name: 'blah', author: User.current.person
    @publisher.expects(:publish).with(@actor, @stories[:create_an_article], @publisher.url_for(blog_post.url))
    blog_post.save!

    # active but published as passive
    User.current = @actor.user
    blog_post = TinyMceArticle.new profile: @enterprise, parent: @enterprise.blog, name: 'blah', author: User.current.person
    @publisher.expects(:publish).with(@actor, @stories[:announce_news_from_a_sse_enterprise], @publisher.url_for(blog_post.url))
    blog_post.save!

    # passive
    User.current = @other_actor.user
    blog_post = TinyMceArticle.new profile: @enterprise, parent: @enterprise.blog, name: 'blah2', author: User.current.person
    @publisher.expects(:publish).with(@actor, @stories[:announce_news_from_a_sse_enterprise], @publisher.url_for(blog_post.url))
    blog_post.save!

    User.current = @other_actor.user
    blog_post = TinyMceArticle.new profile: @community, parent: @community.blog, name: 'blah', author: User.current.person
    @publisher.expects(:publish).with(@actor, @stories[:announce_news_from_a_community], @publisher.url_for(blog_post.url))
    blog_post.save!
  end

end

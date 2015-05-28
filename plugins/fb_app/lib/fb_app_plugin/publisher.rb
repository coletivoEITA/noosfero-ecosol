require 'net/http'

# Publishing example on console
#   pub=FbAppPlugin::Publisher.default; u=Profile['brauliobo']; a=Article.find 307591
#   pub.publish_story a, u, :announce_news_from_a_sse_initiative
#
class FbAppPlugin::Publisher < OpenGraphPlugin::Publisher

  Actions = FbAppPlugin.open_graph_config[:actions]
  Objects = FbAppPlugin.open_graph_config[:objects]

  def initialize attributes = {}
    super
    self.actions = Actions
    self.objects = Objects
  end

  def publish actor, story_defs, object_data_url
    action = self.actions[story_defs[:action]]
    object_type = self.objects[story_defs[:object_type]]
    raise "open_graph: invalid action #{defs[:action]} or object #{defs[:object_type]}" if action.blank? or object_type.blank?
    print_debug "open_graph: action #{action}, object_type #{object_type}" if debug? actor

    auth = actor.fb_app_auth
    return if auth.blank? or auth.expired?
    print_debug "fb_app: Auth found and valid" if debug? actor

    # always update the object to expire facebook cache
    FbAppPlugin::Activity.scrape object_data_url
    return if story_defs[:on] == :update and self.recent_publish? actor, object_type, object_data_url
    print_debug "fb_app: no recent publication found, making new" if debug? actor

    namespace = FbAppPlugin.open_graph_config[:namespace]
    params = {object_type => object_data_url}
    params['fb:explicitly_shared'] = 'true' unless story_defs[:tracker]
    print_debug "fb_app: publishing with params #{params.inspect}" if debug? actor

    me = FbGraph::User.me auth.access_token
    me.og_action! "#{namespace}:#{action}", params
    print_debug "fb_app: published with success" if debug? actor

    register_publish context: self.context, actor_id: actor.id, action: action, object_type: object_type, object_data_url: object_data_url
  end

  protected

  def register_publish attributes
    FbAppPlugin::Activity.create! attributes
  end

  def context
    :fb_app
  end
  def debug? actor=nil
    super or FbAppPlugin.test_user? actor
  end

end

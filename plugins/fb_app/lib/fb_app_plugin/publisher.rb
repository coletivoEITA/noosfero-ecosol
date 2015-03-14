require 'net/http'

class FbAppPlugin::Publisher < OpenGraphPlugin::Publisher

  Actions = FbAppPlugin.open_graph_config[:actions]
  Objects = FbAppPlugin.open_graph_config[:objects]

  UpdateDelay = 1.day

  def initialize attributes = {}
    super
    self.actions = Actions
    self.objects = Objects
  end

  def scrape object_data_url
    params = {id: object_data_url, scrape: true, method: 'post'}
    url = "http://graph.facebook.com?#{params.to_query}"
    Net::HTTP.get URI.parse(url)
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
    scrape object_data_url
    return if recent_publish? actor, object_type, object_data_url

    namespace = FbAppPlugin.open_graph_config[:namespace]
    params = {object_type => object_data_url}
    params['fb:explicitly_shared'] = 'true' unless story_defs[:tracker]
    print_debug "fb_app: publishing with params #{params.inspect}" if debug? actor

    me = FbGraph::User.me auth.access_token
    me.og_action! "#{namespace}:#{action}", params

    register_publish context: self.context, actor_id: actor.id, action: action, object_type: object_type, object_data_url: object_data_url
  end

  protected

  def context
    :fb_app
  end
  def debug? actor=nil
    super or FbAppPlugin.test_user? actor
  end

end

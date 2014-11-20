
class FbAppPlugin::Publisher < OpenGraphPlugin::Publisher

  Actions = FbAppPlugin.config['app']['actions']
  Objects = FbAppPlugin.config['app']['objects']

  def initialize attributes = {}
    super
    self.actions = Actions
    self.objects = Objects
  end

  def publish actor, story_defs, object_data_url
    auth = actor.fb_app_auth
    return if auth.blank? or auth.expired?

    object_type = story_defs[:object_type]
    object_data_url = story_defs[:object_data_url]

    namespace = FbAppPlugin.config['app']['namespace']
    params = {object_type => object_data_url}

    me = FbGraph::User.me auth.access_token
    params['fb:explicitly_shared'] = 'true'
    begin
      me.og_action! "#{namespace}:#{action}", params
    rescue => e
      puts e.message
    end
  end

end

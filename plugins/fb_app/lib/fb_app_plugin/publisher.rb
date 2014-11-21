require 'net/http'

class FbAppPlugin::Publisher < OpenGraphPlugin::Publisher

  Actions = FbAppPlugin.config['app']['actions']
  Objects = FbAppPlugin.config['app']['objects']

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

  def publish on, actor, story_defs, object_data_url
    auth = actor.fb_app_auth
    return if auth.blank? or auth.expired?

    action = self.actions[story_defs[:action]]
    object_type = self.objects[story_defs[:object_type]]

    # always update the object to expires facebook cache
    scrape object_data_url unless on == :create

    activity_params = {actor_id: actor.id, action: action, object_type: object_type, object_data_url: object_data_url}
    activity = OpenGraphPlugin::Activity.where(activity_params).first
    # only scrape recent objects
    return if activity and activity.created_at <= (Time.now + UpdateDelay)
    activity = OpenGraphPlugin::Activity.create! activity_params

    namespace = FbAppPlugin.config['app']['namespace']
    params = {object_type => object_data_url}
    me = FbGraph::User.me auth.access_token
    params['fb:explicitly_shared'] = 'true' unless story_defs[:tracker]
    me.og_action! "#{namespace}:#{action}", params
  end

end

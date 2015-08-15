class FbAppPlugin::Activity < OpenGraphPlugin::Activity

  self.context = :fb_app
  self.actions = FbAppPlugin.open_graph_config[:actions]
  self.objects = FbAppPlugin.open_graph_config[:objects]

  def self.scrape object_data_url
    params = {id: object_data_url, scrape: true, method: 'post'}
    url = "http://graph.facebook.com?#{params.to_query}"
    Net::HTTP.get URI.parse(url)
  end
  def scrape
    self.class.scrape self.object_data_url
  end

  def publish! actor = self.actor
    print_debug "fb_app: action #{self.action}, object_type #{self.object_type}" if debug? actor

    auth = actor.fb_app_auth
    return if auth.blank? or auth.expired?
    print_debug "fb_app: Auth found and is valid" if debug? actor

    # always update the object to expire facebook cache
    Thread.new{ self.scrape }

    return if self.defs[:on] == :update and self.recent_publish? actor, self.object_type, self.object_data_url
    print_debug "fb_app: no recent publication found, making new" if debug? actor

    namespace = FbAppPlugin.open_graph_config[:namespace]
    params = {self.object_type => self.object_data_url}
    params['fb:explicitly_shared'] = 'true' unless self.defs[:tracker]
    print_debug "fb_app: publishing with params #{params.inspect}" if debug? actor

    me = FbGraph2::User.me auth.access_token
    me.og_action! "#{namespace}:#{action}", params

    self.published_at = Time.now
    print_debug "fb_app: published with success" if debug? actor
  end

  protected

  def debug? actor=nil
    super or FbAppPlugin.debug? actor
  end

end

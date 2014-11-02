
module FbAppPlugin::OpenGraph

  PublishProc = proc do |actor, action, object, url|
    auth = actor.fb_app_auth
    return if auth.blank? or auth.expired?

    namespace = FbAppPlugin.config['app']['namespace']
    url = Noosfero::Application.routes.url_helpers.url_for url.except(:port) unless url.is_a? String
    params = {object => url}

    me = FbGraph::User.me auth.access_token
    params['fb:explicitly_shared'] = 'true'
    begin
      me.og_action! "#{namespace}:#{action}", params
    rescue => e
      puts e.message
    end
  end

  Actions = FbAppPlugin.config['app']['actions']
  Objects = FbAppPlugin.config['app']['objects']

end

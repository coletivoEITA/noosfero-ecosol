
module FbAppPlugin::OpenGraph

  def self.publish actor, action, object, url
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

  Actions = [
    :add, :update, :make_friendship,
    :comment, :like, :upload, :start, :favorite,
    :announce_creation, :announce_new, :announce_update, :announce_news,
  ]
  Objects = {
    friendship: :friend,
    product: :sse_product,
    uploaded_file: :cirandas_document,
    image: :cirandas_image,
    forum: :discussion,
    article: :cirandas_article,
  }

  # map objects to a list of stories
  Stories = {
    Friendship: {
      create: proc do |fs, actor|
        # actor is person or friend
        FbAppPlugin::OpenGraph.publish fs.person, :make_friendship, :friend, fs.friend.url
        FbAppPlugin::OpenGraph.publish fs.friend, :make_friendship, :friend, fs.person.url
      end,
    },
    Product: {
      create: proc do |product, actor|
        FbAppPlugin::OpenGraph.publish actor, :add, Objects[:product], product.url
      end,
      update: proc do |product, actor|
        FbAppPlugin::OpenGraph.publish actor, :update, Objects[:product], product.url
      end,
    },
    UploadedFile: {
      create: proc do |uploaded_file, actor|
        FbAppPlugin::OpenGraph.publish actor, :add, Objects[:uploaded_file], uploaded_file.url
      end,
    },
    Image: {
      create: proc do |image, actor|
        break unless image.parent.is_a? Gallery
        FbAppPlugin::OpenGraph.publish actor, :add, Objects[:image], image.url
      end,
    },
    Comment: {
      create: proc do |comment, actor|
        case comment.source
          when Foum
            FbAppPlugin::OpenGraph.publish actor, :comment, Objects[:article], comment.url
            break
          when Article
            FbAppPlugin::OpenGraph.publish actor, :comment, Objects[:article], comment.url
            break
          else
        end
      end,
    },
  }

end

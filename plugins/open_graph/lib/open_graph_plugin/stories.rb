
class OpenGraphPlugin::Stories

  class_attribute :publishers
  self.publishers = []

  ValidObjectList = [
    :friendship,
    :product,
    :uploaded_file,
    :gallery_image,
    :forum,
    :blog_post,
  ]
  ValidActionList = [
    :add,
    :update,
    :make_friendship,
    :comment,
    :like,
    :upload,
    :start,
    :favorite,
    :announce_creation,
    :announce_new,
    :announce_update,
    :announce_news,
  ]

  DefaultActions = ValidActionList.inject({}){ |h, a| h[a] = a; h }
  DefaultObjects = ValidObjectList.inject({}){ |h, o| h[o] = o; h }

  def self.register_publisher actions: DefaultActions, objects: DefaultObjects, &block
    self.publishers << Publisher.new(actions: actions, objects: objects, method: block)
  end

  def self.publish actor, action, object, url
    self.publishers.each do |publisher|
      publisher.publish actor, action, object, url
    end
  end

  # map objects to a list of stories
  Spec = {
    Friendship: {
      create: proc do |fs, actor|
        # actor is person or friend
        OpenGraphPlugin::Stories.publish fs.person, :make_friendship, :friend, fs.friend.url
        OpenGraphPlugin::Stories.publish fs.friend, :make_friendship, :friend, fs.person.url
      end,
    },
    Product: {
      create: proc do |product, actor|
        OpenGraphPlugin::Stories.publish actor, Actions[:add], Objects[:product], product.url
      end,
      update: proc do |product, actor|
        OpenGraphPlugin::Stories.publish actor, Actions[:update], Objects[:product], product.url
      end,
    },
    Article: {
      create: proc do |post, actor|
        parent = post.parent
        return unless post.published? and parent.published and parent.published?
        return unless actor.fb_app_timeline_config.synced_my_activities[:blog_posts]
        OpenGraphPlugin::Stories.publish actor, Actions[:add], Objects[:blog_post], forum.url
      end,
    },
    Forum: {
      create: proc do |forum, actor|
        return unless forum.published?
        OpenGraphPlugin::Stories.publish actor, Actions[:add], Objects[:forum], forum.url
      end,
    },
    UploadedFile: {
      create: proc do |uploaded_file, actor|
        return unless uploaded_file.published?
        OpenGraphPlugin::Stories.publish actor, Actions[:add], Objects[:uploaded_file], uploaded_file.url
      end,
    },
    Image: {
      create: proc do |image, actor|
        break unless image.parent.is_a? Gallery
        OpenGraphPlugin::Stories.publish actor, Actions[:add], Objects[:image], image.url
      end,
    },
    Comment: {
      create: proc do |comment, actor|
        source = comment.source
        return unless source.published?
        case source
          when Forum
            OpenGraphPlugin::Stories.publish actor, Actions[:comment], Objects[:article], comment.url
            break
          when Article
            OpenGraphPlugin::Stories.publish actor, Actions[:comment], Objects[:article], comment.url
            break
          else
        end
      end,
    },
  }

end



class OpenGraphPlugin::Stories

  class_attribute :publishers
  self.publishers = []

  ValidObjectList = [
    :blog_post,
    :enterprise,
    :friendship,
    :forum,
    :gallery_image,
    :person,
    :product,
    :uploaded_file,
  ]
  ValidActionList = [
    :add,
    :comment,
    :create,
    :favorite,
    :like,
    :make_friendship,
    :start,
    :update,
    :upload,
    :announce_creation,
    :announce_new,
    :announce_update,
    :announce_news,
  ]

  DefaultActions = ValidActionList.inject({}){ |h, a| h[a] = a; h }
  DefaultObjects = ValidObjectList.inject({}){ |h, o| h[o] = o; h }

  def self.register_publisher publisher
    self.publishers << publisher
  end

  def self.publish record, on, actor, stories
    self.publishers.each do |publisher|
      publisher.publish_stories record, on, actor, stories
    end
  end

  Definitions = {
    add_a_document: {
      action: :add,
      object_type: :uploaded_file,
      models: :UploadedFile,
      on: :create,
      publish_if: proc do |uploaded_file|
        # done in add_an_image
        return false if uploaded_file.image? and uploaded_file.parent.is_a? Gallery
        uploaded_file.published?
      end,
      object_data_url: proc do |uploaded_file|
        uploaded_file.url.merge view: true
      end,
    },
    add_an_image: {
      action: :add,
      object_type: :gallery_image,
      models: :UploadedFile,
      on: :create,
      publish_if: proc do |uploaded_file|
        uploaded_file.image? and uploaded_file.parent.is_a? Gallery
      end,
      object_data_url: proc do |uploaded_file|
        uploaded_file.url.merge view: true
      end,
    },
    add_a_sse_product: {
      action: :add,
      object_type: :product,
      models: :Product,
      on: :create,
    },
    comment_a_discussion: {
      action: :comment,
      object_type: :forum,
      models: :Comment,
      on: :create,
      criteria: proc do |comment|
        source, parent = comment.source, comment.source.parent
        source.is_a? Article and parent.is_a? Forum
      end,
      publish_if: proc do |comment|
        comment.source.parent.published?
      end,
    },
    comment_an_article: {
      action: :comment,
      object_type: :blog_post,
      models: :Comment,
      on: :create,
      criteria: proc do |comment|
        source, parent = comment.source, comment.source.parent
        source.is_a? Article and parent.is_a? Blog
      end,
      publish_if: proc do |comment|
        comment.source.parent.published?
      end,
    },
    create_an_article: {
      action: :create,
      object_type: :blog_post,
      models: :Article,
      on: :create,
      criteria: proc do |article|
        article.parent.is_a? Blog
      end,
      publish_if: proc do |article|
        article.published?
      end,
    },
    create_an_event: {
      action: :create,
      object_type: :event,
      models: :Event,
      on: :create,
      publish_if: proc do |event|
        event.published?
      end,
    },
    favorite_an_sse_enterprise: {
      action: :create,
      object_type: :favorite_enterprise_person,
      models: :FavoriteEnterprisePerson,
      on: :create,
      publish: proc do |actor, fe, publisher|
        publish actor, actions[:favorite], objects[:enterprise], fe.enterprise.url
      end
    },
    make_friendship_with: {
      action: :make_friendship,
      object_type: :friend,
      models: :Friendship,
      on: :create,
      publish: proc do |actor, fs, publisher|
        publish fs.person, actions[:make_friendship], objects[:friend], publisher.url_for(fs.friend.url)
        publish fs.friend, actions[:make_friendship], objects[:friend], publisher.url_for(fs.person.url)
      end,
    },
    start_a_discussion: {
      action: :start,
      object_type: :forum,
      models: :Article,
      on: :create,
      criteria: proc do |article|
        article.parent.is_a? Forum
      end,
      publish_if: proc do |article|
        article.published?
      end,
    },
    update_a_sse_product: {
      action: :update,
      object_type: :product,
      models: :Product,
      on: :update,
    },
    update_a_sse_enterprise: {
      action: :update,
      object_type: :enterprise,
      models: :Enterprise,
      on: :update,
    },

    # PASSIVE STORIES
    announce_a_new_sse_product: {
      action: :announce_new,
      object_type: :product,
      models: :Product,
      on: :create,
      tracker: true,
    },
    announce_an_update_of_sse_product: {
      action: :announce_update,
      object_type: :product,
      models: :Product,
      on: :update,
      tracker: true,
    },
    announce_news_from_a_community: {
      action: :announce_update,
      object_type: :product,
      models: [:Article, :Image],
      on: [:create, :update],
      tracker: true,
      criteria: proc do |article|
        article.profile.community?
      end,
      publish_if: proc do |object|
        case object
        when Article
          object.published?
        when Image
          object.parent.is_a? Gallery
        end
      end,
    }
  }

  ModelStories = {}; Definitions.each do |story, data|
    Array[data[:models]].each do |model|
      ModelStories[model] ||= {}
      Array(data[:on]).each do |on|
        ModelStories[model][on] ||= []
        ModelStories[model][on] << story
      end
    end
  end

end


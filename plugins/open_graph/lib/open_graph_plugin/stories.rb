
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

  def self.publish record, actor, stories
    self.publishers.each do |publisher|
      publisher.publish_stories record, actor, stories
    end
  end

  Definitions = {
    add_a_document: {
      action: :add,
      object: :uploaded_file,
      models: :UploadedFile,
      on: :create,
      publish_if: proc do |uploaded_file|
        uploaded_file.published?
      end
    },
    add_a_sse_product: {
      action: :create,
      object: :product,
      on: :create,
      models: :Product,
    },
    add_an_image: {
      action: :create,
      object: :gallery_image,
      on: :create,
      models: :Image,
      criteria: proc do |image|
        image.parent.is_a? Gallery
      end,
    },
    comment_a_discussion: {
      action: :comment,
      object: :forum,
      on: :create,
      models: :Comment,
      criteria: proc do |comment|
        source, parent = comment.source, comment.source.parent
        source.is_a? Article and parent.is_a? Forum
      end,
      publish_if: proc do |comment|
        comment.source.parent.published?
      end
    },
    comment_an_article: {
      action: :comment,
      object: :blog_post,
      on: :create,
      models: :Comment,
      criteria: proc do |comment|
        source, parent = comment.source, comment.source.parent
        source.is_a? Article and parent.is_a? Blog
      end,
      publish_if: proc do |comment|
        comment.source.parent.published?
      end
    },
    create_an_article: {
      action: :create,
      object: :blog_post,
      on: :create,
      models: :Article,
      criteria: proc do |article|
        article.parent.is_a? Blog
      end,
      publish_if: proc do |article|
        article.published?
      end
    },
    create_an_event: {
      action: :create,
      object: :event,
      on: :create,
      models: :Event,
      publish_if: proc do |event|
        event.published?
      end
    },
    favorite_an_sse_enterprise: {
      action: :create,
      object: :event,
      on: :create,
      models: :Event,
      publish_if: proc do |event|
        event.published?
      end
    },
    make_friendship_with: {
      action: :make_friendship,
      object: :friend,
      models: :Friendship,
      publish: proc do |fs|
        publish fs.person, actions[:make_friendship], objects[:friend], fs.friend.url
        publish fs.friend, actions[:make_friendship], objects[:friend], fs.person.url
      end
    },
    start_a_discussion: {
      action: :start,
      object: :forum,
      on: :create,
      criteria: proc do |article|
        article.parent.is_a? Forum
      end,
      publish_if: proc do |article|
        article.published?
      end
    },
    update_a_sse_product: {
      action: :update,
      object: :product,
      on: :update,
      models: :Product,
    },
    update_a_sse_enterprise: {
      action: :update,
      object: :enterprise,
      on: :update,
      models: :Enterprise,
    },

    # PASSIVE STORIES
    announce_a_new_sse_product: {
      action: :announce_new,
      object: :product,
      on: :create,
      models: :Product,
      tracker: true,
    },
    announce_an_update_of_sse_product: {
      action: :announce_update,
      object: :product,
      on: :update,
      models: :Product,
      tracker: true,
    },
    announce_news_from_a_community: {
      action: :announce_update,
      object: :product,
      on: :update,
      models: :Article,
      tracker: true,
    }
  }

  ModelStories = {}; Definitions.each do |story, data|
    Array[data[:models]].each do |model|
      ModelStories[model] ||= []
      ModelStories[model] << story
    end
  end

end


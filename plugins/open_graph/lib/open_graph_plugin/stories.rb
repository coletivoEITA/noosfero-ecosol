
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
    :create,
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

  def self.register_publisher publisher
    self.publishers << publisher
  end

  def self.call_hooks record, actor, story_method
    self.publishers.each do |publisher|
      publisher.call_hooks record, actor, story_method
    end
  end

  # map objects to a list of stories
  Spec = {
    Friendship: [:create],
    Product: [:create, :update],
    Article: [:create],
    UploadedFile: [:create],
    Image: [:create],
    Comment: [:create]
  }

end


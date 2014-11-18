
class OpenGraphPlugin::Publisher

  attr_accessor :actions
  attr_accessor :objects
  attr_accessor :method

  def initialize attributes = {}
    attributes.each do |attr, value|
      self.send "#{attr}=", value
    end
  end

  def publish actor, action, object, url
    self.method.call actor, action, object, url
  end

  def call_hooks record, actor, story_method
    self.send story_method, record, actor
  end

  # Definition of the stories - BEGIN
  def on_friendship_create fs, actor
    # Story: "Me and another user became friends in Cirandas"
    # actor is person or friend
    publish fs.person, actions[:make_friendship], objects[:friend], fs.friend.url
    publish fs.friend, actions[:make_friendship], objects[:friend], fs.person.url
  end

  def on_product_create product, actor
    # Story [for the SSE initiative members]: "I added a new SSE product in Cirandas"
    # Story [for the users who favorited the SSE initiative]: "I announce a new SSE product in Cirandas"
    publish actor, actions[:add], objects[:product], product.url
  end

  def on_product_update product, actor
    # Story [for the SSE initiative members]: "I updated a SSE product in Cirandas"
    # Story [for the users who favorited the SSE initiative]: "I announce the update of a SSE product in Cirandas"
    publish actor, actions[:update], objects[:product], product.url
  end

  def on_article_create article, actor
    parent = article.parent
    return unless article.published? and parent.published and parent.published?

    OpenGraphPlugin::Track.profile_trackers(actor)


    case parent
    when Forum, Blog
      # Story [for the author]: "I created a new article in Cirandas"
      # Story [for the users who follow the actor]: "I announce news from a {Friend, Community, SSE Initiative} in Cirandas"
      publish actor, actions[:create], objects[:blog_post], article.url
    else
      # Story [for the author]: "I started a new discussion in Cirandas"
      # Story [for the users who follow the actor]: "I announce news from a {Friend, Community, SSE Initiative} in Cirandas"
      publish actor, actions[:create], objects[:forum], article.url
    end
  end

  def on_uploadedfile_create uploaded_file, actor
    # Story [for the SSE initiative members]: "I uploaded a new document in Cirandas"
    # Story [for the users who favorited the SSE initiative]: "I announce news from a {Friend, Community, SSE Initiative} in Cirandas"
    return unless uploaded_file.published?
    publish actor, actions[:add], objects[:uploaded_file], uploaded_file.url
  end

  def on_image_create image, actor
    # Story [for the SSE initiative members]: "I added a new image in Cirandas"
    # Story [for the users who favorited the SSE initiative]: "I announce news from a {Friend, Community, SSE Initiative} in Cirandas"
    return unless image.parent.is_a? Gallery
    publish actor, actions[:add], objects[:image], image.url
  end

  def on_comment_create comment, actor
    source = comment.source
    return if source.respond_to? :published? and not source.published?
    case source
      when Forum
        publish actor, actions[:comment], objects[:article], comment.url
      when Article
        publish actor, actions[:comment], objects[:article], comment.url
      else
    end
  end
  # Definition of the stories - END

end


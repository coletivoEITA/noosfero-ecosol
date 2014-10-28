require_dependency 'songkick/oauth2/model/client'

class Songkick::OAuth2::Model::Client

  attr_accessible :site, :image_builder

  validates_presence_of :site

  acts_as_having_image
  after_update :save_image

  def image_public_filename size='icon'
    self.image.public_filename size if self.image
  end

  protected

  def save_image
    image.save if image
  end

end

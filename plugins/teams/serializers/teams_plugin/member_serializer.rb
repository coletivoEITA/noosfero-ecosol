class TeamsPlugin::MemberSerializer < ActiveModel::Serializer

  attributes :id, :name, :image_url

  def name
    self.profile.name
  end

  def image_url
    return "/images/icons-app/person-#{:minor}.png" unless self.profile.image
    self.profile.image.public_filename :minor
  end

  protected

  def profile
    @profile ||= if self.object.is_a? Profile then self.object else self.object.profile end
  end

end


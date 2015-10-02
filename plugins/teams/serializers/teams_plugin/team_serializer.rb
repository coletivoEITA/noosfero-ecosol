class TeamsPlugin::TeamSerializer < ActiveModel::Serializer

  attributes :id, :name

  has_many :members, serializer: TeamsPlugin::MemberSerializer

  def members
    self.object.members
  end

end


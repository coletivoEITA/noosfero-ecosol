class TeamsPlugin::TeamSerializer < ApplicationSerializer

  attributes :id, :name

  has_many :members, serializer: TeamsPlugin::MemberSerializer

  def members
    self.object.members
  end

end


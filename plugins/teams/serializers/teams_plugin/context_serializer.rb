class TeamsPlugin::ContextSerializer < ActiveModel::Serializer

  attributes :context

  has_many :teams, serializer: TeamsPlugin::TeamSerializer

  def context
    {id: self.object.id, type: self.object.class.base_class.name}
  end

  def teams
    self.object.teams
  end

end

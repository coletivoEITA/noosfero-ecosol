class TeamsPlugin::ContextSerializer < ApplicationSerializer

  attributes :context, :allow_edit

  has_many :teams, serializer: TeamsPlugin::TeamSerializer

  def context
    {id: self.object.id, type: self.object.class.base_class.name}
  end

  def allow_edit
    return unless self.object.respond_to? :allow_edit?
    self.object.allow_edit? User.current.person or self.object.environment.has_admin? User.current.person
  end

  def teams
    self.object.teams.order('name ASC')
  end

end

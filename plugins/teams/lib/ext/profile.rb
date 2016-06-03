require_dependency 'profile'

class Profile

  has_many :teams, class_name: 'TeamsPlugin::Team', as: :context

end

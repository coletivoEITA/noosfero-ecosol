require_dependency 'article'

class Article

  has_many :teams, class_name: 'TeamsPlugin::Team', as: :context

end

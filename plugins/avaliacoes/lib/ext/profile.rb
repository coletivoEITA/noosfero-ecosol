require_dependency 'profile'

class Profile

  has_one :avaliacoes_user, primary_key: :identifier, foreign_key: :ID, class_name: 'AvaliacoesPlugin::User'
  has_many :avaliacoes_grades, through: :avaliacoes_user, source: :grades

end

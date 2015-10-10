class AvaliacoesPlugin::LearningUnit < AvaliacoesPlugin::ActiveRecord

  self.table_name = :cursos

  belongs_to :responsible, foreign_key: :Responsavel, class_name: 'User'
  belongs_to :user, foreign_key: :Usuario, class_name: 'User'

  has_many :courses, foreign_key: :CodCursos
  has_many :activities, foreign_key: :CodCurso

end

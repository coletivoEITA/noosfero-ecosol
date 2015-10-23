class AvaliacoesPlugin::Activity < AvaliacoesPlugin::ActiveRecord

  self.table_name = :aulas

  belongs_to :learning_unit, foreign_key: :CodCurso

  has_many :questions, foreign_key: :CodAula
  has_many :answers, through: :questions

end

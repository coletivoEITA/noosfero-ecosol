class AvaliacoesPlugin::LearningUnitStudent < AvaliacoesPlugin::ActiveRecord

  self.table_name = :curso_alunos

  belongs_to :learning_unit, foreign_key: :CodCurso
  belongs_to :student, foreign_key: :CodUser

end

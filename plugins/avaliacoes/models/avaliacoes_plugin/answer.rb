class AvaliacoesPlugin::Answer < AvaliacoesPlugin::ActiveRecord

  self.table_name = :aulas_avaliacoes_alunos_respostas

  belongs_to :student, foreign_key: :CodAluno
  belongs_to :question, foreign_key: :CodAvaliacao
  belongs_to :learning_unit, foreign_key: :CodCurso
  belongs_to :activity, foreign_key: :CodAula

end

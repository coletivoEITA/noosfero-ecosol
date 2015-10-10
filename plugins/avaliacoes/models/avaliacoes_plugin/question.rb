class AvaliacoesPlugin::Question < AvaliacoesPlugin::ActiveRecord

  self.table_name = :aulas_avaliacoes

  belongs_to :activity, foreign_key: :CodAula
  belongs_to :learning_unit, foreign_key: :CodCurso

  scope :essay, -> { where Tipo: 'DS' }
  scope :multiple_choice, -> { where Tipo: 'MP' }

end

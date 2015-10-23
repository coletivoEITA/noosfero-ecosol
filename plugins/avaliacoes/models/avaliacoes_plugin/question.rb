class AvaliacoesPlugin::Question < AvaliacoesPlugin::ActiveRecord

  self.table_name = :aulas_avaliacoes

  alias_attribute :index, :IndexQuestao
  alias_attribute :learning_unit_id, :CodCurso

  belongs_to :activity, foreign_key: :CodAula
  belongs_to :learning_unit, foreign_key: :CodCurso

  has_many :grades, foreign_key: :CodAvaliacao

  scope :essay, -> { where aulas_avaliacoes: {Tipo: 'DS'} }
  scope :multiple_choice, -> { where aulas_avaliacoes: {Tipo: 'MP'} }

  def essay?
    self.Tipo == 'DS'
  end
  def multiple_choice?
    self.Tipo == 'MP'
  end

end

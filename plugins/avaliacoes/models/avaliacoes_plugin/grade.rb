class AvaliacoesPlugin::Grade < AvaliacoesPlugin::ActiveRecord

  self.table_name = :notas_frequencia

  alias_attribute :learning_unit_id, :CodCurso
  alias_attribute :grade, :Nota
  alias_attribute :answered, :Frequencia

  belongs_to :student, foreign_key: :CodAluno

  belongs_to :learning_unit, foreign_key: :CodCurso
  belongs_to :activity, foreign_key: :CodAula
  belongs_to :question, foreign_key: :CodAvaliacao

  has_many :discipline_units, foreign_key: :CodGrup, primary_key: :CodGrupo

  scope :from_discipline, -> name {
    # grup_curso -> DisciplineUnit
    joins(:discipline_units).where(grup_curso: {ID: name})
  }
  scope :from_learning_unit, -> name {
    # grup_curso -> DisciplineUnit
    joins(:discipline_units).where(grup_curso: {NomeCurso: name})
  }

  scope :from_question_type, -> type {
    # aulas_avaliacoes -> Question
    joins(:question).where(aulas_avaliacoes: {Tipo: type})
  }

  Conceitos = {
    0 => 'Não Informado',
    1 => 'Insatisfatório',
    2 => 'Satisfatório',
    3 => 'Bom',
    4 => 'Ótimo',
  }

end

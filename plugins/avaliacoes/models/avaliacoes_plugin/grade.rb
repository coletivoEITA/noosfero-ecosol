class AvaliacoesPlugin::Grade < AvaliacoesPlugin::ActiveRecord

  self.table_name = :notas_frequencia

  belongs_to :user, foreign_key: :CodAluno
  belongs_to :activity, foreign_key: :CodAula
  belongs_to :learning_unit, foreign_key: :CodCurso
  belongs_to :question, foreign_key: :CodAvaliacao

  scope :from_identifier, -> identifier {
    joins(:learning_unit).where '"cursos"."Nome" LIKE ?', "#{identifier.upcase}-%"
  }

end

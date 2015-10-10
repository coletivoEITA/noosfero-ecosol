class AvaliacoesPlugin::Activity < AvaliacoesPlugin::ActiveRecord

  self.table_name = :aulas

  belongs_to :learning_unit, foreign_key: :CodCurso

end

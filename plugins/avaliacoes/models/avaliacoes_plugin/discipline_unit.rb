class AvaliacoesPlugin::DisciplineUnit < AvaliacoesPlugin::ActiveRecord

  self.table_name = :grup_curso

  alias_attribute :name, :ID

  belongs_to :learning_unit, foreign_key: :CodCursos
  # table does not exist
  #belongs_to :discipline, foreign_key: :CodGrup

  has_many :activities, through: :learning_unit
  has_many :questions, through: :activities
  has_many :answers, through: :questions

end

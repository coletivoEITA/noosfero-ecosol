class AvaliacoesPlugin::GroupCourse < AvaliacoesPlugin::ActiveRecord

  self.table_name = :grup_curso

  belongs_to :group, foreign_key: :CodCursos

  has_many :units

end

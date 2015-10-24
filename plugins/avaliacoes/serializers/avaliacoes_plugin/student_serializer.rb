class AvaliacoesPlugin::StudentSerializer < ActiveModel::Serializer

  has_many :disciplines

  def disciplines
    AvaliacoesPlugin::Discipline.map_one self.object
  end

end

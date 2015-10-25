class AvaliacoesPlugin::StudentSerializer < ActiveModel::Serializer

  has_many :disciplines

  def disciplines
    AvaliacoesPlugin::Discipline.map self.object
  end

end

class AvaliacoesPlugin::StudentSerializer < ApplicationSerializer

  has_many :disciplines

  def disciplines
    AvaliacoesPlugin::Discipline.map self.object
  end

end

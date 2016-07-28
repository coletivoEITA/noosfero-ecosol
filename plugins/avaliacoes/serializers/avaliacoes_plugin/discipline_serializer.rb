class AvaliacoesPlugin::DisciplineSerializer < ApplicationSerializer

  attribute :name

  has_many :learning_units, serializer: AvaliacoesPlugin::LearningUnitSerializer

end

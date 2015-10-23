class AvaliacoesPlugin::DisciplineSerializer < ActiveModel::Serializer

  attribute :name

  has_many :learning_units, serializer: AvaliacoesPlugin::LearningUnitSerializer

end

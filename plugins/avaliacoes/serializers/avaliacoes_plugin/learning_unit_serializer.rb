class AvaliacoesPlugin::LearningUnitSerializer < ApplicationSerializer

  attribute :name

  has_many :essay_grades, serializer: AvaliacoesPlugin::GradeSerializer
  has_many :multiple_choice_grades, serializer: AvaliacoesPlugin::GradeSerializer

end

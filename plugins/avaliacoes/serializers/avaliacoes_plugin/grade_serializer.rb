class AvaliacoesPlugin::GradeSerializer < ActiveModel::Serializer

  attribute :grade

  belongs_to :question

end

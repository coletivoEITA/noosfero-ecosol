class AvaliacoesPlugin::GradeSerializer < ActiveModel::Serializer

  attribute :grade
  attribute :answered

  belongs_to :question

  def grade
    self.object.grade.to_f
  end

end

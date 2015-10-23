class AvaliacoesPlugin::LearningUnit < AvaliacoesPlugin::ActiveRecord

  self.table_name = :cursos

  attr_accessor :student

  belongs_to :responsible, foreign_key: :Responsavel, class_name: 'Student'
  belongs_to :owner, foreign_key: :Usuario, class_name: 'Student'

  has_many :activities, foreign_key: :CodCurso
  has_many :questions, through: :activities
  has_many :answers, -> { includes :question }, through: :questions

  alias_attribute :name, :Nome

  def essay_grades
    return [] unless self.student
    self.student.grades.select do |g|
      g.grade.nonzero? and
      g.question.learning_unit_id == self.id and g.question.essay?
    end.sort_by{ |g| g.question.index }
  end
  def multiple_choice_grades
    return [] unless self.student
    self.student.grades.select do |g|
      g.question.learning_unit_id == self.id and g.question.multiple_choice?
    end.sort_by{ |g| g.question.index }
  end

end

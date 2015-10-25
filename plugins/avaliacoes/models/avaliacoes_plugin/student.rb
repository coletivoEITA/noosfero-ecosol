class AvaliacoesPlugin::Student < AvaliacoesPlugin::ActiveRecord

  self.table_name = :usuarios

  alias_attribute :name, :Nome

  attr_accessor :units

  belongs_to :profile, foreign_key: :ID, primary_key: :identifier, class_name: '::Profile'
  belongs_to :user, foreign_key: :Mail, primary_key: :email, class_name: '::User'

  has_many :responsible_units, foreign_key: :Responsavel, class_name: 'LearningUnit'
  has_many :owned_units, foreign_key: :Usuario, class_name: 'LearningUnit'

  has_many :grades, -> { eager_load :question }, foreign_key: :CodAluno
  has_many :answers, foreign_key: :CodAluno
  has_many :grades_discipline_units, -> { distinct }, through: :grades

  has_many :student_learning_units, foreign_key: :CodUser, class_name: 'LearningUnitStudent'
  has_many :learning_units, through: :student_learning_units
  has_many :discipline_units, -> { distinct }, through: :learning_units

  has_many :activities, through: :grades
  has_many :questions, through: :grades

end

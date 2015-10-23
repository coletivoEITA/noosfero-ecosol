class AvaliacoesPlugin::Student < AvaliacoesPlugin::ActiveRecord

  self.table_name = :usuarios

  belongs_to :profile, foreign_key: :ID, primary_key: :identifier, class_name: '::Profile'
  belongs_to :user, foreign_key: :Mail, primary_key: :email, class_name: '::User'

  has_many :responsible_units, foreign_key: :Responsavel, class_name: 'LearningUnit'
  has_many :owned_units, foreign_key: :Usuario, class_name: 'LearningUnit'

  # prefer the has_many :through
  has_many :direct_grades, foreign_key: :CodAluno, class_name: 'Grade'

  has_many :discipline_units, through: :direct_grades
  has_many :activities, through: :discipline_units
  has_many :questions, through: :activities

  has_many :grades, -> s { distinct.includes(:question).where notas_frequencia: {CodAluno: s.id} }, through: :questions

  has_many :answers, through: :questions

end

class AvaliacoesPlugin::User < AvaliacoesPlugin::ActiveRecord

  self.table_name = :usuarios

  belongs_to :profile, foreign_key: :ID, primary_key: :identifier, class_name: '::Profile'
  belongs_to :user, foreign_key: :Mail, primary_key: :email, class_name: '::User'

  has_many :responsible_units, foreign_key: :Responsavel, class_name:'LearningUnit'
  # DON'T USE
  has_many :learning_units, foreign_key: :Usuario

  has_many :grades, foreign_key: :CodAluno, class_name: 'AvaliacoesPlugin::Grade'

end

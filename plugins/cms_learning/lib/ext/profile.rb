require_dependency 'profile'

class Profile
  has_many :knowledges, :source => :articles, :class_name => 'CmsLearningPluginLearning'
end

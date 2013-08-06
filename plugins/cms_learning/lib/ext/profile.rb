require_dependency 'profile'

class Profile

  has_many :knowledges, :source => :articles, :class_name => 'CmsLearningPlugin::Learning'

end

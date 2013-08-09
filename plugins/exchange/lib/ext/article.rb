require_dependency 'article'

class Article

  has_many :elements, :foreign_key => :object_id, :conditions => {:object_type => "CmsLearningPlugin::Learning"},
    :class_name => 'ExchangePlugin::Element', :dependent => :destroy

end

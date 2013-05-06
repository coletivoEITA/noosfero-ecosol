require_dependency 'article'

class Article
  has_many :elements, :foreign_key => "element_id", :conditions => {:element_type => "CmsLearningPluginLearning"}, :class_name => 'ExchangePlugin::ExchangeElement', :dependent => :destroy
end

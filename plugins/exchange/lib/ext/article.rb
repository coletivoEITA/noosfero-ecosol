require_dependency 'article'

class Article

  has_many :elements, -> {
    where object_type: 'CmsLearningPlugin::Learning'
  }, foreign_key: :object_id, class_name: 'ExchangePlugin::Element', dependent: :destroy

end

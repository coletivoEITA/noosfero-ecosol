require_dependency 'comment'

ActiveSupport.run_load_hooks :solr_comment

class Comment

  after_save :solr_notify_article
  after_destroy :solr_notify_article

  def solr_notify_article
    article.solr_comments_updated if article.kind_of?(Article)
  end

  acts_as_searchable fields: SEARCHABLE_FIELDS.map{ |field, options|
    {field => {boost: options[:weight]}}
  }

end

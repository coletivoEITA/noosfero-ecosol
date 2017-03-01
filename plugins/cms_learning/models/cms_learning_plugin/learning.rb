class CmsLearningPlugin::Learning < Article

  attr_accessible :name, :body, :summary, :good_practices, :product_category_string_ids, :person_string_ids

  settings_items :summary, type: :string, default: ""
  settings_items :good_practices, type: :string, default: ""

  has_many :resources, foreign_key: 'article_id', order: 'id asc', class_name: 'ArticleResource', dependent: :destroy
  has_many :resources_product_categories, foreign_key: 'article_id', order: 'id asc', class_name: 'ArticleResource',
    conditions: ['article_resources.resource_type = ?', 'ProductCategory']

  has_many :resources_persons, foreign_key: 'article_id', order: 'id asc', class_name: 'ArticleResource',
    conditions: ['article_resources.resource_type = ?', 'Person']

  has_many :product_categories, through: :resources, source: :product_category, foreign_key: 'article_id', readonly: true,
    class_name: 'ProductCategory', conditions: ['article_resources.resource_type = ?', 'ProductCategory']

  has_many :persons, through: :resources, source: :person, foreign_key: 'article_id', readonly: true,
    class_name: 'Person', conditions: ['article_resources.resource_type = ?', 'Person']

  scope :by_profile, lambda { |profile| { conditions: {profile_id: profile.id} } }

  def self.type_name
    _('Learning')
  end

  def self.short_description
    _('Learning')
  end

  def self.description
    _('Share learnings to the network.')
  end

  def self.icon_name(article = nil)
    'cms-learning'
  end

  def self.type_name
    _('Learning')
  end

  def to_html(options = {})
    lambda do
      render file: 'cms/cms_learning_plugin_page'
    end
  end

  def default_parent
    profile.articles.find_by_name _('Learnings'), conditions: {type: 'Folder'}
  end

  def use_media_panel?
    true
  end

  def tiny_mce?
    true
  end

  def product_category_string_ids
    ''
  end

  def person_string_ids
    ''
  end

  def product_category_string_ids=(ids)
    ids = ids.split(',')
    r = ProductCategory.find(ids)
    self.resources_product_categories.destroy_all
    @res_product_categories = ids.collect{ |id| r.detect{ |x| x.id == id.to_i } }.map do |pc|
      ArticleResource.new resource_id: pc.id, resource_type: ProductCategory.name
    end
  end

  def person_string_ids=(ids)
    ids = ids.split(',')
    r = Person.find(ids)
    self.resources_persons.destroy_all
    @res_persons = ids.collect{ |id| r.detect{ |x| x.id == id.to_i } }.map do |pc|
      ArticleResource.new resource_id: pc.id, resource_type: Person.name
    end
  end

  protected

  after_save :save_associated
  def save_associated
    @res_product_categories.each{ |c| c.article_id = self.id; c.save! } unless @res_product_categories.blank?
    @res_persons.each{ |p| p.article_id = self.id; p.save! } unless @res_persons.blank?
  end

end

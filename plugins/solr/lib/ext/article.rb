require_dependency 'article'

ActiveSupport.run_load_hooks :solr_article

class Article

  # use for internationalizable human type names in search facets
  # reimplement on subclasses
  def self.type_name
    c_('Content')
  end

  def solr_comments_updated
    solr_save
  end

  def add_category_with_solr_save(c, reload=false)
    add_category_without_solr_save(c, reload)
    if !new_record?
      self.solr_save
    end
  end
  alias_method_chain :add_category, :solr_save

  def create_pending_categorizations_with_solr_save
    create_pending_categorizations_without_solr_save
    self.solr_save
  end
  alias_method_chain :create_pending_categorizations, :solr_save

  protected

  def self.solr_f_type_proc(facet, id_count_arr)
    id_count_arr.map do |type, count|
      [type, type.constantize.type_name, count]
    end
  end

  def self.solr_f_profile_type_proc facet, id_count_arr
    id_count_arr.map do |type, count|
      [type, type.constantize.type_name, count]
    end
  end

  def solr_f_type
    #join common types
    case self.class.name
    when 'TinyMceArticle', 'TextileArticle'
      TextArticle.name
    else
      self.class.name
    end
  end

  def solr_f_profile_type
    self.profile.class.name
  end

  def solr_f_published_at
    self.published_at
  end

  def solr_f_category
    self.categories.collect(&:name)
  end

  def solr_public
    self.public?
  end

  def solr_category_filter
    categories_including_virtual_ids
  end

  def solr_name_sortable
    name
  end

  acts_as_faceted fields: {
      solr_f_type: {label: c_('Type'), proc: method(:solr_f_type_proc).to_proc},
      solr_f_published_at: {type: :date, label: _('Published date'), queries: {'[* TO NOW-1YEARS/DAY]' => _("Older than one year"),
        '[NOW-1YEARS TO NOW/DAY]' => _("In the last year"), '[NOW-1MONTHS TO NOW/DAY]' => _("In the last month"), '[NOW-7DAYS TO NOW/DAY]' => _("In the last week"), '[NOW-1DAYS TO NOW/DAY]' => _("In the last day")},
        queries_order: ['[NOW-1DAYS TO NOW/DAY]', '[NOW-7DAYS TO NOW/DAY]', '[NOW-1MONTHS TO NOW/DAY]', '[NOW-1YEARS TO NOW/DAY]', '[* TO NOW-1YEARS/DAY]']},
      solr_f_profile_type: {label: c_('Profile'), proc: method(:solr_f_profile_type_proc).to_proc},
      solr_f_category: {label: c_('Categories')},
    }, category_query: -> (c) { "solr_category_filter:\"#{c.id}\"" },
    order: [:solr_f_type, :solr_f_published_at, :solr_f_profile_type, :solr_f_category]

  acts_as_searchable fields: [
      # searched fields
      {name: {type: :text, boost: 2.0}},
      {slug: :text}, {body: :text},
      {abstract: :text}, {filename: :text},
      # filtered fields
      {solr_public: :boolean}, {published: :boolean},
      {environment_id: :integer},
      {profile_id: :integer}, :language,
      {solr_category_filter: :integer},
      # ordered/query-boosted fields
      {lat: :float}, {lng: :float},
      {solr_name_sortable: :string}, :last_changed_by_id, :published_at, :is_image,
      :updated_at, :created_at,
    ],
    include: [
      {profile: {fields: [:name, :identifier, :address, :nickname, :region_id, :lat, :lng]}},
      {comments: {fields: [:title, :body, :author_name, :author_email]}},
      {categories: {fields: [:name, :path, :slug, :lat, :lng, :acronym, :abbreviation]}},
    ], facets: self.solr_facets_options,
    boost: -> (a) { 10 if a.profile && a.profile.enabled },
    if: -> (a) { not a.class.name.in? ['RssFeed'] }

  # we don't need this with NRT from solr 5
  #handle_asynchronously :solr_save
  # solr_destroy don't work with delayed_job, as AR won't be found
  #handle_asynchronously :solr_destroy

end

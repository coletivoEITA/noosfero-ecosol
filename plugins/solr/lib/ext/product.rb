require_dependency 'product'

ActiveSupport.run_load_hooks :solr_product

class Product

  SEARCH_FILTERS[:order].unshift 'relevance'
  SEARCH_FILTERS[:order] << 'closest'

  after_save_reindex [:enterprise], with: :delayed_job

  # overwrite on subclasses
  def solr_index?
    true
  end

  def solr_boost
    boost = 1;
    SolrPlugin::Boosts.each do |b|
      boost = boost * (1 - ((1 - b[2].call(self)) * b[1]))
    end
    boost
  end

  protected

  alias_method :solr_ac_name, :name
  alias_method :solr_ac_category, :category_name

  def solr_supplier
    values = [self.profile.name, self.profile.short_name]
    values.concat [self.supplier.name, self.supplier.name_abbreviation] if defined? SuppliersPlugin
    values
  end
  def solr_ac_supplier
    self.solr_supplier
  end

  def solr_f_category
    self.product_category.name
  end

  def solr_f_region
    self.enterprise.region_id.to_s
  end

  def self.solr_f_region_proc *args
    Profile.solr_f_region_proc *args
  end

  def self.solr_f_qualifier_proc facet, id_count_arr
    ids, qualis_hash, certs_hash = {}, {}, {}
    id_count_arr.each do |id, count|
      array = id.split ' '
      ids[array[0]] = array[1]
    end
    Qualifier.find(ids.keys).each{ |q| qualis_hash[q.id.to_s] = q.name }
    Certifier.find(ids.values.compact).each{ |c| certs_hash[c.id.to_s] = c.name }

    count_hash = Hash[id_count_arr]
    ids.map do |qid, cid|
      id = "#{qid} #{cid}"
      qualifier = qualis_hash[qid]
      certifier = certs_hash[cid]
      name = certifier ? [qualifier, _(' cert. ') + certifier] : qualifier
      [id, name, count_hash[id]]
    end
  end

  def solr_f_qualifier
    product_qualifiers.map do |pq|
      "#{pq.qualifier_id} #{pq.certifier_id}"
    end
  end

  def solr_category_filter
    enterprise.categories_including_virtual_ids << product_category_id
  end

  def solr_public
    # environment.products only consider enterprises
    self.public? and self.profile.enterprise?
  end

  def solr_available_sortable
    if self.available then '1' else '0' end
  end

  def solr_highlighted_sortable
    if self.highlighted then '1' else '0' end
  end

  def solr_name_sortable # give a different name for solr
    name
  end

  def solr_price_sortable
    (price.nil? or price.zero?) ? nil : price
  end

  def solr_unarchived
    !self.archived
  end

  acts_as_faceted fields: {
      solr_f_category: {label: _('Related products'), context_criteria: -> { !empty_search? } },
      solr_f_region: {label: c_('City'), proc: method(:solr_f_region_proc).to_proc},
      solr_f_qualifier: {label: c_('Qualifiers'), proc: method(:solr_f_qualifier_proc).to_proc},
    }, category_query: -> (c) { "solr_category_filter:#{c.id}" },
    order: [:solr_f_category, :solr_f_region, :solr_f_qualifier]

  SolrPlugin::Boosts = [
    [:highlighted, 0.9, -> (p) { if p.highlighted and p.available then 1 else 0 end }],
    [:available, 0.9, -> (p) { if p.available then 1 else 0 end }],
    [:image, 0.55, -> (p) { if p.image then 1 else 0 end }],
    [:qualifiers, 0.45, -> (p) { if p.product_qualifiers.count > 0 then 1 else 0 end }],
    [:open_price, 0.45, -> (p) { if p.price_described? then 1 else 0 end }],
    [:solidarity, 0.45, -> (p) { p.percentage_from_solidarity_economy[0].to_f/100 }],
    [:price, 0.35, -> (p) { if (!p.price.nil? and p.price > 0) then 1 else 0 end }],
    [:new_product, 0.35, -> (p) { if (p.updated_at.to_i - p.created_at.to_i) < 24*3600 then 1 else 0 end }],
    [:description, 0.3, -> (p) { if !p.description.blank? then 1 else 0 end }],
    [:enabled, 0.2, -> (p) { if p.enterprise and p.enterprise.enabled then 1 else 0 end }],
  ]

  acts_as_searchable fields: [
      # searched fields
      {name: {type: :text, boost: 2.0}},
      {solr_supplier: {type: :text}},
      {description: :text}, {category_full_name: :text},
      # filtered fields
      {solr_public: :boolean},
      {environment_id: :integer}, {profile_id: :integer},
      {enabled: :boolean}, {solr_category_filter: :integer},
      {available: :boolean}, {archived: :boolean}, {highlighted: :boolean},
      {solr_unarchived: :boolean},
      # fields for autocompletion
      {solr_ac_name: :ngram_text},
      {solr_ac_category: :ngram_text},
      {solr_ac_supplier: {type: :ngram_text}},
      # ordered/query-boosted fields
      {solr_available_sortable: :string}, {solr_highlighted_sortable: :string},
      {solr_price_sortable: :decimal}, {solr_name_sortable: :string},
      {lat: :float}, {lng: :float},
      :updated_at, :created_at,
    ],
    include: [
      {product_category: {fields: [:name, :path, :slug, :lat, :lng, :acronym, :abbreviation]}},
      {region: {fields: [:name, :path, :slug, :lat, :lng]}},
      {enterprise: {fields: [:name, :identifier, :address, :nickname, :lat, :lng]}},
      {qualifiers: {fields: [:name]}},
      {certifiers: {fields: [:name]}},
    ], facets: self.solr_facets_options,
    boost: -> (p) { p.solr_boost },
    if: -> (p) { p.solr_index? }

  # we don't need this with NRT from solr 5
  #handle_asynchronously :solr_save
  # solr_destroy don't work with delayed_job, as AR won't be found
  #handle_asynchronously :solr_destroy

end

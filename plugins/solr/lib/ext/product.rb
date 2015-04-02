require_dependency 'product'

class Product

  SEARCH_FILTERS[:order] << 'closest'

  after_save_reindex [:enterprise], with: :delayed_job

  # overwrite on subclasses
  def solr_index?
    true
  end

  def solr_plugin_boost
    boost = 1;
    SolrPlugin::Boosts.each do |b|
      boost = boost * (1 - ((1 - b[2].call(self)) * b[1]))
    end
    boost
  end

  protected

  alias_method :solr_plugin_ac_name, :name
  alias_method :solr_plugin_ac_category, :category_name

  def solr_plugin_f_category
    self.product_category.name
  end

  def solr_plugin_f_region
    self.enterprise.region_id.to_s
  end

  def self.solr_plugin_f_region_proc *args
    Profile.solr_plugin_f_region_proc *args
  end

  def self.solr_plugin_f_qualifier_proc facet, id_count_arr
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

  def solr_plugin_f_qualifier
    product_qualifiers.map do |pq|
      "#{pq.qualifier_id} #{pq.certifier_id}"
    end
  end

  def solr_plugin_category_filter
    enterprise.categories_including_virtual_ids << product_category_id
  end

  def solr_plugin_public
    self.public?
  end

  def solr_plugin_available_sortable
    if self.available then '1' else '0' end
  end

  def solr_plugin_highlighted_sortable
    if self.highlighted then '1' else '0' end
  end

  def solr_plugin_name_sortable # give a different name for solr
    name
  end

  def solr_plugin_price_sortable
    (price.nil? or price.zero?) ? nil : price
  end

  def solr_plugin_unarchived
    !self.archived
  end

  acts_as_faceted fields: {
      solr_plugin_f_category: {label: _('Related products'), context_criteria: proc{ !empty_search? } },
      solr_plugin_f_region: {label: c_('City'), proc: method(:solr_plugin_f_region_proc).to_proc},
      solr_plugin_f_qualifier: {label: c_('Qualifiers'), proc: method(:solr_plugin_f_qualifier_proc).to_proc},
    }, category_query: proc { |c| "solr_plugin_category_filter:#{c.id}" },
    order: [:solr_plugin_f_category, :solr_plugin_f_region, :solr_plugin_f_qualifier]

  SolrPlugin::Boosts = [
    [:highlighted, 0.9, proc{ |p| if p.highlighted and p.available then 1 else 0 end }],
    [:available, 0.9, proc{ |p| if p.available then 1 else 0 end }],
    [:image, 0.55, proc{ |p| if p.image then 1 else 0 end }],
    [:qualifiers, 0.45, proc{ |p| if p.product_qualifiers.count > 0 then 1 else 0 end }],
    [:open_price, 0.45, proc{ |p| if p.price_described? then 1 else 0 end }],
    [:solidarity, 0.45, proc{ |p| p.percentage_from_solidarity_economy[0].to_f/100 }],
    [:price, 0.35, proc{ |p| if (!p.price.nil? and p.price > 0) then 1 else 0 end }],
    [:new_product, 0.35, proc{ |p| if (p.updated_at.to_i - p.created_at.to_i) < 24*3600 then 1 else 0 end }],
    [:description, 0.3, proc{ |p| if !p.description.blank? then 1 else 0 end }],
    [:enabled, 0.2, proc{ |p| if p.enterprise and p.enterprise.enabled then 1 else 0 end }],
  ]

  acts_as_searchable fields: facets_fields_for_solr + [
      # searched fields
      {name: {type: :text, boost: 2.0}},
      {description: :text}, {category_full_name: :text},
      # filtered fields
      {solr_plugin_public: :boolean},
      {environment_id: :integer}, {profile_id: :integer},
      {enabled: :boolean}, {solr_plugin_category_filter: :integer},
      {available: :boolean}, {archived: :boolean}, {highlighted: :boolean},
      {solr_plugin_unarchived: :boolean},
      # fields for autocompletion
      {solr_plugin_ac_name: :ngram_text},
      {solr_plugin_ac_category: :ngram_text},
      # ordered/query-boosted fields
      {solr_plugin_available_sortable: :string}, {solr_plugin_highlighted_sortable: :string},
      {solr_plugin_price_sortable: :decimal}, {solr_plugin_name_sortable: :string},
      {lat: :float}, {lng: :float},
      :updated_at, :created_at,
    ], include: [
      {product_category: {fields: [:name, :path, :slug, :lat, :lng, :acronym, :abbreviation]}},
      {region: {fields: [:name, :path, :slug, :lat, :lng]}},
      {enterprise: {fields: [:name, :identifier, :address, :nickname, :lat, :lng]}},
      {qualifiers: {fields: [:name]}},
      {certifiers: {fields: [:name]}},
    ], facets: facets_option_for_solr,
    boost: proc{ |p| p.solr_plugin_boost },
    if: proc{ |p| p.solr_index? }

  # we don't need this with NRT from solr 5
  #handle_asynchronously :solr_save
  # solr_destroy don't work with delayed_job, as AR won't be found
  #handle_asynchronously :solr_destroy

end

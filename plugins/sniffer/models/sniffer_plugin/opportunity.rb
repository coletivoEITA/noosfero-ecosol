class SnifferPlugin::Opportunity < ActiveRecord::Base

  attr_accessible *self.column_names

  belongs_to :profile

  belongs_to :opportunity, polymorphic: true

  # for has_many :through
  belongs_to :product_category, class_name: 'ProductCategory', foreign_key: :opportunity_id,
    conditions: ['sniffer_plugin_opportunities.opportunity_type = ?', 'ProductCategory']
  # getter
  def product_category
    opportunity_type == 'ProductCategory' ? opportunity : nil
  end

  scope :product_categories, {
    conditions: ['sniffer_plugin_opportunities.opportunity_type = ?', 'ProductCategory']
  }

  delegate :lat, :lng, to: :product_category, allow_nil: true

  if defined? SolrPlugin
    acts_as_searchable fields: [
        # searched fields
        # filtered fields
        {profile_id: :integer},
        # ordered/query-boosted fields
        {lat: :float}, {lng: :float},
      ], include: [
        {product_category: {fields: [:name, :path, :slug, :lat, :lng, :acronym, :abbreviation]}},
      ]

    handle_asynchronously :solr_save
  end

  # delegate missing methods to opportunity
  def method_missing method, *args, &block
    if self.opportunity.respond_to? method
      self.opportunity.send method, *args, &block
    else
      super method, *args, &block
    end
  end
  def respond_to_with_profile? method
    respond_to_without_profile? method or self.opportunity.class.new.respond_to? method
  end
  alias_method_chain :respond_to?, :profile

end

class SnifferPlugin::Opportunity < Noosfero::Plugin::ActiveRecord

  belongs_to :profile

  belongs_to :opportunity, :polymorphic => true

  # for has_many :through
  belongs_to :product_category, :class_name => 'ProductCategory', :foreign_key => :opportunity_id,
    :conditions => ['sniffer_plugin_opportunities.opportunity_type = ?', 'ProductCategory']
  # getter
  def product_category
    opportunity_type == 'ProductCategory' ? opportunity : nil
  end

  named_scope :product_categories, {
    :conditions => ['sniffer_plugin_opportunities.opportunity_type = ?', 'ProductCategory']
  }

  delegate :lat, :lng, :to => :product_category, :allow_nil => true

  if defined? SolrPlugin
    acts_as_searchable :fields => [
        # searched fields
        # filtered fields
        {:profile_id => :integer},
        # ordered/query-boosted fields
        {:lat => :float}, {:lng => :float},
      ], :include => [
        {:product_category => {:fields => [:name, :path, :slug, :lat, :lng, :acronym, :abbreviation]}},
      ]

    handle_asynchronously :solr_save
  end

end

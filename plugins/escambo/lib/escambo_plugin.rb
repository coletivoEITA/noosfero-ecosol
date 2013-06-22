require 'cms_learning_plugin'
require 'currency_plugin'
require 'evaluation_plugin'
require 'exchange_plugin'
require 'signup_with_enterprise_plugin'
require 'sniffer_plugin'
require 'solr_plugin'

class EscamboPlugin < Noosfero::Plugin

  def self.plugin_name
    "EscamboPlugin"
  end

  def self.plugin_description
    _("ESCAMBO network integration plugin")
  end

  def stylesheet?
    true
  end

  SearchLimit = 20
  SearchIndexFilter = proc do
    if @query.empty?
      options = {:limit => SearchLimit, :conditions => ['created_at IS NOT NULL'], :order => 'created_at DESC'}
      @interests = SnifferPluginOpportunity.all options
      @products = Product.all options
      @knowledges = CmsLearningPluginLearning.all options
    else
      @interests = find_by_contents(:sniffer_plugin_opportunities, SnifferPluginOpportunity, @query, paginate_options).results
      @products = find_by_contents(:products, Product, @query, paginate_options)[:results].results
      @knowledges = find_by_contents(:cms_learning_plugin_learnings, CmsLearningPluginLearning, @query, paginate_options)[:results].results
    end
    @results = @interests + @products + @knowledges
    @results = @results.sort_by{ |r| r.created_at }
    @results = @results.last SearchLimit

    # overwrite controller action
    render :action => :index
  end
  def search_controller_filters
    [
      {:type => 'before_filter', :method_name => 'escambo_search_index',
       :options => {:only => :index}, :block => SearchIndexFilter},
    ]
  end

  HomeIndexFilter = proc do

    # overwrite controller action
    render :action => :index
  end
  def home_controller_filters
    [
      {:type => 'before_filter', :method_name => 'escambo_home_index',
       :options => {:only => :index}, :block => HomeIndexFilter},
    ]
  end

  ProfileIndexFilter = proc do
    return unless profile.enterprise?

    render :action => 'index'
  end
  def profile_controller_filters
    [
      {:type => 'before_filter', :method_name => 'escambo_profile_index',
       :options => {:only => :index}, :block => ProfileIndexFilter},
    ]
  end

  CatalogIndexFilter = proc do
    redirect_to :controller => :profile, :action => :products
  end
  def catalog_controller_filters
    [
      {:type => 'before_filter', :method_name => 'escambo_catalog_index',
       :options => {:only => :index}, :block => CatalogIndexFilter},
    ]
  end

  #implementation followed app/helpers/application_helper.rb
  #method profile_image_link
  def profile_image_link profile
    return unless profile.enterprise?
    lambda do
      product_categories = profile.product_categories
      exchange_icon = '-not'
      #should call ExchangePlugin.exchanges.state=conluded
      escambo_sumary = {:exchanges_count => 23, :enterprises_count => 17}

      render :file => 'escambo_plugin_shared/profile_image_link',
             :locals => {
               :profile => profile,
               :product_categories => product_categories,
               :escambo_sumary => escambo_sumary,
               :exchange_icon => exchange_icon,
             }
    end
  end

end

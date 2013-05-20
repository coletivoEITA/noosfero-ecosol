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
    options = {:limit => SearchLimit, :conditions => ['created_at IS NOT NULL'], :order => 'created_at desc'}
    @interests = SnifferPluginOpportunity.all options
    @products = Product.all options
    @knowledges = CmsLearningPluginLearning.all options

    @results = @interests + @products + @knowledges
    @results = @results.sort_by{ |r| r.created_at }
    @results = @results.last SearchLimit

    # overwrite controller action
    render :action => :index
  end

  def search_controller_filters
    [
      {:type => 'before_filter', :method_name => 'escambo_searches',
       :options => {:only => :index}, :block => SearchIndexFilter},
    ]
  end

  #implementation followed app/helpers/application_helper.rb
  #method profile_image_link
  def profile_image_link profile
    return unless profile.enterprise?
    lambda do
      product_categories = profile.product_categories

      #should call ExchangePlugin.exchanges.state=conluded
      escambo_sumary = {:exchanges_count => 23, :enterprises_count => 17}

      render :file => 'escambo_plugin_shared/profile_image_link',
             :locals => {
               :profile => profile,
               :product_categories => product_categories,
               :escambo_sumary => escambo_sumary
             }
    end
  end

end

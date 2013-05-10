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

end

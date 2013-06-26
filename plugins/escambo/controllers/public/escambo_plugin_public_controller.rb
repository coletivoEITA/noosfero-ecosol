class EscamboPluginPublicController < PublicController

  def enterprise_search
    @query = params[:query]
    @results = environment.enterprises.visible.all :limit => 10, :conditions => ['LOWER(name) ~ ?', @query]
    @results = @results - [@profile]
    render :partial => 'enterprise_results'
  end

end

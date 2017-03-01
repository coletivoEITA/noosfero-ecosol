class EscamboPluginPublicController < PublicController

  def enterprise_search
    @query = params[:query].to_s.downcase
    @enterprises = environment.enterprises.visible.all :limit => 10, :conditions => ['LOWER(name) ~ ?', @query]
    render :partial => 'enterprise_results'
  end

end


class FbesPluginQueriesController < PublicController

  FbesPlugin::Queries::Hash.each do |name, query|
    define_method name do
      page = (params[:page] || 1).to_i
      per_page = (params[:per_page] || 20).to_i

      query = "#{query} offset #{page*per_page} limit #{per_page}"
      result = nil
      ActiveRecord::Base.transaction do
        result = ActiveRecord::Base.connection.execute query
      end

      render :json => result.to_json
    end
  end

  protected

end

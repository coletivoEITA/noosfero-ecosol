require 'fastercsv'

class FbesPluginQueriesController < PublicController

  FbesPlugin::Queries::Hash.each do |name, query|
    define_method name do
      page = (params[:page] || 1).to_i
      per_page = (params[:per_page] || 20).to_i
      format = params[:format]
      request.format = format.to_sym if format.present?

      query = "#{query} offset #{page*per_page} limit #{per_page}"
      result = ActiveRecord::Base.transaction do
        ActiveRecord::Base.connection.execute query
      end

      respond_to do |format|
        format.json do
          render :json => result.to_json
        end
        format.csv do
          csv = FasterCSV.generate do |csv|
            csv << result.fields
            result.each{ |r| csv << r.values }
          end
          render :text => csv
        end
      end
    end
  end

  protected

end

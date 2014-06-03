require 'fastercsv'

class FbesPluginQueriesController < PublicController

  FbesPlugin::Queries::Hash.each do |name, query|
    define_method name do
      page = (params[:page] || 1).to_i
      per_page = (params[:per_page] || 20).to_i
      format = params[:format]
      request.format = format.to_sym if format.present?

      query = "#{query} offset #{(page-1)*per_page} limit #{per_page}"
      result = ActiveRecord::Base.transaction do
        ActiveRecord::Base.connection.execute query
      end

      # make ordered hashes. FIXME: remove with ruby > 1.9
      new_result = result.map do |record|
        new_record = ActiveSupport::OrderedHash.new
        result.fields.each do |key|
          new_record[key] = record[key]
        end
        new_record
      end
      result = new_result

      respond_to do |format|
        format.json do
          render :json => result.to_json
        end
        format.csv do
          csv = FasterCSV.generate do |csv|
            csv << result.first.keys
            result.each{ |r| csv << r.values }
          end
          render :text => csv
        end
      end
    end
  end

  protected

end

#require 'fastercsv'

class FbesPluginQueriesController < PublicController

  before_filter :login_required
  protect 'view_environment_admin_panel', :environment

  FbesPlugin::Queries::Hash.each do |name, query|
    define_method name do
      page = (params[:page] || 1).to_i
      per_page = if params[:per_page] == 'all' then nil else (params[:per_page] || 20).to_i end
      format = params[:format]
      request.format = format.to_sym if format.present?

      query_with_pagination = if not per_page then query else "#{query} offset #{(page-1)*per_page} limit #{per_page}" end
      result = ActiveRecord::Base.transaction do
        ActiveRecord::Base.connection.execute query_with_pagination
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
      @fbes_plugin_result = result
      @fbes_plugin_queries = FbesPlugin::Queries::Hash

      respond_to do |format|
        format.json do
          render :json => result.to_json
        end
        format.csv do
          #csv = FasterCSV.generate do |csv|
          #  csv << result.first.keys
          #  result.each{ |r| csv << r.values }
          #end
          #send_csv csv
        end
        format.html do
          render 'show_html'
        end
      end
    end
  end

  protected

  def send_csv csv
    send_data csv, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=#{params[:action]}.csv"
  end

end

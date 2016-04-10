class FbesPlugin::QueriesController < PublicController

  before_filter :login_required
  protect 'view_environment_admin_panel', :environment
  no_design_blocks

  FbesPlugin::Queries::Hash.each do |name, query|
    define_method name do
      @npage = (params[:page] || 1).to_i
      @per_page = if params[:per_page] == 'all' then nil else (params[:per_page] || 20).to_i end
      format = params[:format]
      request.format = format.to_sym if format.present?

      query_with_pagination = if not @per_page then query else "#{query} offset #{(@npage-1)*@per_page} limit #{@per_page}" end
      @result = ActiveRecord::Base.transaction do
        ActiveRecord::Base.connection.execute query_with_pagination
      end
      @result_full_count = @result.first['full_count']
      @result_pages = if @per_page then (@result_full_count.to_f / @per_page.to_f).ceil else 1 end

      respond_to do |format|
        format.json do
          render json: @result.to_json
        end
        format.csv do
          csv = CSV.generate do |csv|
            csv << @result.first.keys
            @result.each{ |r| csv << r.values }
          end
          send_csv csv
        end
        format.html do
          render :show
        end
      end
    end
  end

  protected

  def send_csv csv
    send_data csv, type: 'text/csv; charset=utf-8; header=present', disposition: "attachment; filename=#{params[:action]}.csv"
  end

  # inherit routes from core skipping use_relative_controller!
  def url_for options
    options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
    super options
  end
  helper_method :url_for

end

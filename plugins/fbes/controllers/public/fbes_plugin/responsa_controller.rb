class FbesPlugin::ResponsaController < PublicController

  def enterprises
      @enterprises = environment.enterprises.enabled

      @page = (params[:page] || 1).to_i
      @per_page = if params[:per_page] == 'all' then 999999 else (params[:per_page] || 20).to_i end
      @enterprises = @enterprises.paginate page: @page, per_page: @per_page

      @json = @enterprises.map do |e|
        {
          local_id: e.id,
          url: url_for(e.url),
          title: e.short_name(null),
          description: e.description,
          lat: e.lat,
          lng: e.lng,
          address: [e.address, e.address_line2, e.district, e.zip_code].select{ |f| f.present? }.join(', '),
          city: e.city,
          state: e.state,
          country: 'BR',
          created_at: e.created_at,
          updated_at: e.updated_at,
          avatar: if e.image then "#{environment.top_url}#{e.image.public_filename}" else nil end,
        }
      end

      render json: @json
  end

  protected

  def default_url_options
    # avoid rails' use_relative_controller!
    {use_route: '/'}
  end

end


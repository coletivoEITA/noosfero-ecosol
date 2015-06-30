class FbesPlugin::ResponsaController < PublicController

  def initiatives
    @last_updated_on = params[:last_updated_on] || 24
    @last_updated_on = @last_updated_on.months.ago

    @enterprises = environment.enterprises.enabled.joins(:products, :articles).
      where('profiles.updated_at > ? OR products.updated_at > ? OR articles.updated_at > ?', @last_updated_on, @last_updated_on, @last_updated_on).
      uniq.group('profiles.id')
    @consumers_coops = environment.communities.joins(:orders).
      where('orders_plugin_orders.updated_at > ?', @last_updated_on).
      uniq.group('profiles.id')

    @results = @enterprises + @consumers_coops

    @json = @results.map do |e|
      {
        local_id: e.id,
        url: url_for(e.url),
        title: e.short_name(nil),
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
      }.compact
    end

    render json: Oj.dump(@json, mode: :compat)
  end

  protected

  def default_url_options
    # avoid rails' use_relative_controller!
    {use_route: '/'}
  end

end


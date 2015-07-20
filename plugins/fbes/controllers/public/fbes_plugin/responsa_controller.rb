class FbesPlugin::ResponsaController < PublicController

  def initiatives
    @last_updated_on = params[:last_updated_on] || 24
    @last_updated_on = @last_updated_on.to_i.months.ago

    @enterprises = environment.enterprises.visible.enabled.
      joins(:articles).joins('left join products on products.profile_id = profiles.id').
      where('profiles.updated_at > ? OR products.updated_at > ? OR articles.updated_at > ?', @last_updated_on, @last_updated_on, @last_updated_on).
      where('lat IS NOT NULL AND lng IS NOT NULL').
      uniq.group('profiles.id')
    @consumers_coops = environment.communities.joins(:orders).
      where('orders_plugin_orders.updated_at > ?', @last_updated_on).
      where('lat IS NOT NULL AND lng IS NOT NULL').
      uniq.group('profiles.id')

    @results = @enterprises + @consumers_coops

    @json = @results.map do |r|
      r.description ||= if r.is_a? Enterprise then 'Empreendimento de Economia Solidária' else 'Grupo de Consumo Responsável' end
      {
        local_id: r.id,
        url: url_for(r.url),
        title: r.short_name(nil),
        description: r.description,
        lat: r.lat,
        lng: r.lng,
        address: [r.address, r.address_line2, r.district].select{ |f| f.present? }.join(', '),
        zip_code: r.zip_code,
        phone1: r.contact_phone,
        city: r.city,
        state: r.state,
        country: 'BR',
        created_at: r.created_at,
        updated_at: r.updated_at,
        avatar: if r.image then "#{environment.top_url}#{r.image.public_filename}" else nil end,
      }.tap{ |h| h.delete_if{ |k, v| k.nil? } }
    end

    render json: Oj.dump(@json, mode: :compat)
  end

  protected

  def default_url_options
    # avoid rails' use_relative_controller!
    {use_route: '/'}
  end

end


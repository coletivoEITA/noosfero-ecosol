class ThemesApiPluginApiController < PublicController

  def fetch_enterprises
    if user
      @enterprises = user.enterprises.select{ |e| e.admins.include? user }
      @enterprises = @enterprises.map{ |e| {:name => e.short_name, :identifier => e.identifier, :logo => (e.image.public_filename(nil) rescue nil) } }

      render :json => {:user => user.identifier, :enterprises => @enterprises}
    else
      render :json => {:user => nil}
    end
  end

  def create_theme
    @themes_path = ThemesApiPlugin::ThemesPath
    @profile = environment.profiles.find_by_identifier params[:profile]
    return render :json => {:error => {:code => 1, :message => 'not an admin'}} if @profile.blank? or not @profile.admins.include? user

    @base_theme = params[:base_theme]
    return render :json => {:error => {:code => 2, :message => 'could not find base theme'}} unless File.directory? "#{@themes_path}/#{@base_theme}"

    @theme_id = "#{ThemesApiPlugin::NamePrefix}-#{@profile.identifier}"

    @sass_variables = ActiveSupport::OrderedHash.new
    @sass_variables.update params[:sass_variables]
    @sass_variables['theme-name'] = "\"#{@theme_id}\""

    ret = system "rm -fr #{@themes_path}/#{@theme_id} && cp -fr #{@themes_path}/#{@base_theme}/ #{@themes_path}/#{@theme_id}"
    return render :json => {:error => {:code => 3, :message => 'could not copy theme'}} unless ret

    ret = File.open "#{@themes_path}/#{@theme_id}/stylesheets/_variables.scss", "w" do |file|
      file << @sass_variables.map do |name, value|
        next unless name.present? and value.present?
        "$#{name}: #{value};"
      end.join("\n")
    end.present?
    return render :json => {:error => {:code => 4, :message => 'could not write variables'}} unless ret

    File.open("#{@themes_path}/#{@theme_id}/theme.yml", 'w') do |file|
      file << {
        'name' => "Seu tema personalizado",
        'layout' => "cirandas-responsive",
        'jquery_theme' => "smoothness",
        'icon_theme' => ['awesome', 'pidgin'],
        'responsive' => true,
        'owner_id' => @profile.id,
        'owner_type' => @profile.type.to_s,
      }.to_yaml
    end

    ret = system "rm -f public/assets/designs/themes/#{@theme_id}/stylesheets/style*.css" #ensure sass compilation

    @profile.theme = @theme_id
    @profile.save

    render :json => {:error => {:code => 0, :message => 'success'}}
  end


end

module ThemeHelper

  def theme_path
    if session[:theme]
      '/user_themes/' + current_theme
    else
      '/designs/themes/' + current_theme
    end
  end

  def current_theme
    @current_theme ||=
      begin
        if session[:theme]
          session[:theme]
        else
          # utility for developers: set the theme to 'random' in development mode and
          # you will get a different theme every request. This is interesting for
          # testing
          if ENV['RAILS_ENV'] == 'development' && environment.theme == 'random'
            @random_theme ||= Dir.glob('public/designs/themes/*').map { |f| File.basename(f) }.rand
            @random_theme
          elsif ENV['RAILS_ENV'] == 'development' && respond_to?(:params) && params[:theme] && File.exists?(File.join(Rails.root, 'public/designs/themes', params[:theme]))
            params[:theme]
          else
            if profile && !profile.theme.nil?
              profile.theme
            elsif environment
              environment.theme
            else
              if logger
                logger.warn("No environment found. This is weird.")
                logger.warn("Request environment: %s" % request.env.inspect)
                logger.warn("Request parameters: %s" % params.inspect)
              end

              # could not determine the theme, so return the default one
              'default'
            end
          end
        end
      end
  end

  def theme_view_file(template)
    ['.rhtml', '.html.erb'].each do |ext|
      file = (RAILS_ROOT + '/public' + theme_path + '/' + template + ext)
      return file if File.exists?(file)
    end
    nil
  end

  def theme_include(template, options = {})
    file = theme_view_file(template)
    options.merge!({:file => file, :use_full_path => false})
    if file
      render options
    else
      nil
    end
  end

  def theme_favicon
    return '/designs/themes/' + current_theme + '/favicon.ico' if profile.nil? || profile.theme.nil?
    if File.exists?(File.join(RAILS_ROOT, 'public', theme_path, 'favicon.ico'))
      '/designs/themes/' + profile.theme + '/favicon.ico'
    else
      favicon = profile.articles.find_by_path('favicon.ico')
      if favicon
        favicon.public_filename
      else
        '/designs/themes/' + environment.theme + '/favicon.ico'
      end
    end
  end

  def theme_site_title
    @theme_site_title ||= theme_include 'site_title'
  end

  def theme_header
    @theme_header ||= theme_include 'header'
  end

  def theme_footer
    @theme_footer ||= theme_include 'footer'
  end

  def theme_extra_navigation
    @theme_extra_navigation ||= theme_include 'navigation'
  end

  def is_testing_theme
    !@controller.session[:theme].nil?
  end

  def theme_owner
    Theme.find(current_theme).owner.identifier
  end

  def theme_option(opt = nil)
    conf = RAILS_ROOT.to_s() +
           '/public' + theme_path +
           '/theme.yml'
    if File.exists?(conf)
      opt ? YAML.load_file(conf)[opt.to_s()] : YAML.load_file(conf)
    else
      nil
    end
  end

  def theme_opt_menu_search
    opt = theme_option( :menu_search )
    if    opt == 'none'
      ""
    elsif opt == 'simple_search'
      s = _('Search...')
      "<form action=\"#{url_for(:controller => 'search', :action => 'index')}\" id=\"simple-search\" class=\"focus-out\""+
      ' help="'+_('This is a search box. Click, write your query, and press enter to find')+'"'+
      ' title="'+_('Click, write and press enter to find')+'">'+
      '<input name="query" value="'+s+'"'+
      ' onfocus="if(this.value==\''+s+'\'){this.value=\'\'} this.form.className=\'focus-in\'"'+
      ' onblur="if(/^\s*$/.test(this.value)){this.value=\''+s+'\'} this.form.className=\'focus-out\'">'+
      '</form>'
    else
      colorbox_link_to '<span class="icon-menu-search"></span>'+ _('Search'), {
                       :controller => 'search',
                       :action => 'popup',
                       :category_path => (@category ? @category.explode_path : []) },
                       :id => 'open_search'
    end
  end

  def theme_javascript
    option = theme_option(:js)
    return if option.nil?
    html = []
    option.each do |file|
      file = theme_path +
             '/javascript/'+ file +'.js'
      if File.exists? RAILS_ROOT.to_s() +'/public'+ file
        html << javascript_src_tag( file, {} )
      else
        html << '<!-- Not included: '+ file +' -->'
      end
    end
    html.join "\n"
  end

  def theme_javascript_src
    script = File.join theme_path, 'theme.js'
    script if File.exists? File.join(Rails.root, 'public', script)
  end

  def theme_javascript_ng
    script = theme_javascript_src
    if script then javascript_include_tag script else '' end
  end

  def theme_stylesheet_path
    theme_path + '/style.css'
  end

end

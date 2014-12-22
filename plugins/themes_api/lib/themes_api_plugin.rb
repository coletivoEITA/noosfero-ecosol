class ThemesApiPlugin < Noosfero::Plugin

  NamePrefix = "tantascores"
  ThemesPath = "#{Rails.root}/public/designs/themes"

  def self.plugin_name
    "Themes API"
  end

  def self.plugin_description
    "Methods to fetch user's organizations info and change theirs' themes"
  end

  def stylesheet?
    false
  end

  def js_files
    [].map{ |j| "javascripts/#{j}" }
  end


end

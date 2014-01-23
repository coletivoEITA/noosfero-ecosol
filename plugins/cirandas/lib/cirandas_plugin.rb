class CirandasPlugin < Noosfero::Plugin

  def self.plugin_name
    "Cirandas"
  end

  def self.plugin_description
    "Customizações do CIRANDAS"
  end

  def stylesheet?
    true
  end

  def js_files
    ['cirandas'].map{ |j| "javascripts/#{j}" }
  end

end

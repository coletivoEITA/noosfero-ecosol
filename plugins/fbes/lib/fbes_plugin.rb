class FbesPlugin < Noosfero::Plugin

  def plugin_name
    "FBES API"
  end

  def plugin_description
    "API de empreendimentos para o FBES"
  end

  def stylesheet?
    false
  end

  def js_files
    [].map{ |j| "javascripts/#{j}" }
  end

end


class WebODFPlugin::Base < Noosfero::Plugin

  def content_types
    [WebODFPlugin::Document]
  end

end


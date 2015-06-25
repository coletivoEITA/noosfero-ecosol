class DiagramoPlugin < Noosfero::Plugin

  def self.plugin_name
    "Integração com o diagramo"
  end

  def self.plugin_description
    "Um novo conteúdo que integra o diagramo"
  end

  def content_types
    [DiagramoPlugin::Diagram]
  end

  def stylesheet?
    true
  end

  def article_toolbar_actions article
    user = context.send :user
    return unless user and user.is_admin? environment
    return unless article.folder?
    lambda do
      render 'content_viewer/diagramo_plugin/new_diagram_button', :article => article
    end
  end

end

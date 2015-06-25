require_dependency 'environment'

class Environment

  def diagramo_settings
    @diagramo_settings ||= Noosfero::Plugin::Settings.new self, DiagramoPlugin
  end
  def diagramo_settings= hash
    hash.each do |attr, value|
      self.diagramo_settings.send "#{attr}=", value
    end
  end
end


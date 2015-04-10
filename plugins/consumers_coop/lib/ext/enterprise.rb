require_dependency 'enterprise'

class Enterprise

  def closed?
    !self.consumers_coop_settings.enabled
  end

end


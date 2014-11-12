class OpenGraphPlugin::EnterpriseTrack < OpenGraphPlugin::Track

  def self.objects
    [
      :product,
    ]
  end

  validates_inclusion_of :object, in: self.objects

end

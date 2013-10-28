class NetworksPlugin::Node < NetworksPlugin::BaseNode

  before_validation :generate_identifier

  protected

  def generate_identifier
    self.identifier = Digest::MD5.hexdigest rand.to_s
  end

end

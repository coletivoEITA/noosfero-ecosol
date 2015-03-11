module SmssyncPlugin

  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    "Smssync"
  end

  def self.plugin_description
    "Smssync by Ushahidi"
  end

  def self.config
    @config ||= HashWithIndifferentAccess.new(YAML.load File.read("#{File.dirname __FILE__}/../config.yml")) rescue {}
  end

  def self.secret
    @secret ||= self.config[:secret]
  end

end

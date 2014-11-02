
class OpenGraphPlugin::Publisher

  attr_accessor :actions
  attr_accessor :objects
  attr_accessor :method

  def initialize attributes = {}
    attributes.each do |attr, value|
      self.send "#{attr}=", value
    end
  end

  def publish actor, action, object, url
    instance_exec actor, action, object, url, &self.method
  end

end


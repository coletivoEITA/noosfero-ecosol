begin
  require 'fb_app_plugin'
rescue LoadError
end

class MetadataPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t 'metadata_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t 'metadata_plugin.lib.plugin.description'
  end

  class_attribute :og_type_namespace
  self.og_type_namespace = FbAppPlugin.config['app']['namespace'] if defined? FbAppPlugin

  def head_ending
    lambda do
      options = MetadataPlugin::Spec::Controllers[controller.controller_path.to_sym]
      options ||= MetadataPlugin::Spec::Controllers[:profile] if controller.is_a? ProfileController
      options ||= MetadataPlugin::Spec::Controllers[:environment]
      return unless options
      return unless object = instance_variable_get(options[:variable])
      return unless metadata = object.class.const_get(:Metadata)
      metadata.map do |property, contents|
        contents = contents.call object rescue nil if contents.is_a? Proc
        next unless contents

        Array(contents).map do |content|
          content = content.call object rescue nil if content.is_a? Proc
          next unless content
          tag 'meta', property: property, content: content
        end.join
      end.join
    end
  end

  protected

end




class MetadataPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t 'metadata_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t 'metadata_plugin.lib.plugin.description'
  end

  def self.config
    @config ||= HashWithIndifferentAccess.new(YAML.load File.read("#{File.dirname __FILE__}/../config.yml")) rescue {}
  end

  def self.og_type_namespace
    @og_type_namespace ||= self.config[:open_graph][:type_namespace]
  end
  def self.og_types
    @og_types ||= self.config[:open_graph][:types]
  end

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

ActiveSupport.run_load_hooks :metadata_plugin, MetadataPlugin


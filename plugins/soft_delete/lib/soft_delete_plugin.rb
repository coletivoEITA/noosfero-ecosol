module SoftDeletePlugin

  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    _'Soft delete for models'
  end

  def self.plugin_description
    _'Default to soft delete instead of real delete on supported models'
  end

end

require 'soft_delete_plugin/model_methods'


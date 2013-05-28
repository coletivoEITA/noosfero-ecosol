require_dependency "#{File.dirname __FILE__}/ext/profile"

class CmsLearningPlugin < Noosfero::Plugin

  def self.plugin_name
    "CmsLearning"
  end

  def self.plugin_description
    _("Share your knowledge to the network.")
  end

  def self.view_path
    (RAILS_ROOT + '/plugins/cms_learning/views')
  end

  def stylesheet?
    true
  end

  def js_files
    []
  end

  def profile_blocks(profile)
    CmsLearningPlugin::LearningsBlock
  end

  def content_types
    [CmsLearningPluginLearning]
  end

  def search_controller_filter
    [{
      :type => 'before_filter',
      :method_name => 'append_view_path',
      :options => {},
      :block => lambda { @controller.append_view_path CmsLearningPlugin.view_path }
    }]
  end

end

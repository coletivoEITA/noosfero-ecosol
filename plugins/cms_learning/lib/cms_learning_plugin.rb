
class CmsLearningPlugin < Noosfero::Plugin

  def self.plugin_name
    "CmsLearning"
  end

  def self.plugin_description
    _("Share your knowledge to the network.")
  end

  def stylesheet?
    true
  end

  def js_files
    ['cms_learning.js'].map{ |j| "javascripts/#{j}" }
  end

  def profile_blocks profile
    CmsLearningPlugin::LearningsBlock
  end

  def content_types
    [CmsLearningPlugin::Learning]
  end

end

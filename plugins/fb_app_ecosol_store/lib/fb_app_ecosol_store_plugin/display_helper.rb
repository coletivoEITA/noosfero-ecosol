module FbAppEcosolStorePlugin::DisplayHelper

  protected

  def self.included base
    base.send :include, ActionView::Helpers::UrlHelper
    base.alias_method_chain :link_to, :target_blank
  end

  def link_to_with_target_blank name = nil, options = nil, html_options = nil, &block
    html_options ||= {}
    html_options[:target] = '_blank'
    link_to_without_target_blank name, options, html_options, &block
  end

end

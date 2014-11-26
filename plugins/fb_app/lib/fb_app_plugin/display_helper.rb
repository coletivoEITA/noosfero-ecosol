module FbAppPlugin::DisplayHelper

  protected

  def self.included base
    base.send :include, ActionView::Helpers::UrlHelper
    base.alias_method_chain :link_to, :target_blank
    base.alias_method_chain :link_to_product, :iframe
  end

  def link_to_product_with_iframe product, options = {}
    link_to content_tag('span', product.name),
            params.merge(controller: :fb_app_plugin, product_id: product.id),
            options.merge(target: '')
  end

  def link_to_with_target_blank name = nil, options = nil, html_options = nil, &block
    html_options ||= {}
    html_options[:target] ||= '_parent'
    link_to_without_target_blank name, options, html_options, &block
  end

end

module FbAppPlugin::DisplayHelper

  protected

  def self.included base
    base.send :include, ActionView::Helpers::UrlHelper
    base.alias_method_chain :link_to, :target
    base.alias_method_chain :link_to_product, :iframe
  end

  def link_to_product_with_iframe product, opts = {}
    url_opts = opts.delete(:url_options) || {}
    url_opts.merge controller: :fb_app_plugin, product_id: product.id
    url = params.merge url_opts
    link_to content_tag('span', product.name), url,
      opts.merge(target: '')
  end

  def link_to_with_target name = nil, options = nil, html_options = nil, &block
    html_options ||= {}
    html_options[:target] ||= '_parent'
    link_to_without_target name, options, html_options, &block
  end

end

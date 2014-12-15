module FbAppPlugin::DisplayHelper

  protected

  def link_to_product product, opts = {}
    url_opts = opts.delete(:url_options) || {}
    url_opts.merge! controller: :fb_app_plugin_page_tab, product_id: product.id
    domain = FbAppPlugin.config[:app][:domain]
    url_opts[:host] = domain if domain.present?
    url_opts[:protocol] = '//'

    url = params.merge url_opts
    link_to content_tag('span', product.name), url,
      opts.merge(target: '')
  end

  def link_to name = nil, options = nil, html_options = nil, &block
    html_options ||= {}
    options[:protocol] = '//'
    html_options[:target] ||= '_parent'
    super
  end

end

# add target attribute to links
class FbAppEcosolStorePlugin::LinkRenderer < WillPaginate::LinkRenderer

  def prepare collection, options, template
    super
  end

  protected

  # 2.x version
  def page_link page, text, attributes = {}
    @template.link_to text, url_for(page), attributes.merge(:target => '')
  end

  # 3.x version
  def link text, target, attributes = {}
    page_link target, text, attributes
  end

end

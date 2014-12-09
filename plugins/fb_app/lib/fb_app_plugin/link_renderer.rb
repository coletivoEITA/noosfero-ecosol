# add target attribute to links
class FbAppPlugin::LinkRenderer < WillPaginate::ViewHelpers::LinkRenderer

  def prepare collection, options, template
    super
  end

  protected

  def link text, target, attributes = {}
    self.template.link_to text, self.template.url_for(target), attributes.merge(target: '')
  end

end

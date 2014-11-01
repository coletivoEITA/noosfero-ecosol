require_dependency 'product'

UserStampSweeper.observe Product

class Product

  extend FbAppPlugin::AttachStories::ClassMethods
  fb_app_attach_stories

end

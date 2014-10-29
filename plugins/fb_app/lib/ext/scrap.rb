require 'scrap'

class Scrap

  after_create :fb_app_publish

  protected

  def fb_app_publish
    raise 'here'
  end
  handle_asynchronously :fb_app_publish

end

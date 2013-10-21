module ExchangePlugin::ImageHelper

  # image that can be aligned, centered, and resized with aspect ratio
  def profile_link_with_image profile, size=:portrait
    link = link_to '', profile.url, :class => "inner", :style => "background-image: url(#{profile_icon profile, size})"
    content_tag 'div', link, :class => "profile-image #{size}"
  end

end

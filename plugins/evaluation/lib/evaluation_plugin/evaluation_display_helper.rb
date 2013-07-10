module EvaluationPlugin::EvaluationDisplayHelper

  include ApplicationHelper

  # image that can be aligned, centered, and resized with aspect ratio
  def profile_link_with_image profile, size=:portrait
     link_to '', profile.url, :class => "profile-image #{size}", :style => "background-image: url(#{profile_icon profile, size})"
  end

end

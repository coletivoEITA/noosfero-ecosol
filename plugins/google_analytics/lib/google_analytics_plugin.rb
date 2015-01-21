class GoogleAnalyticsPlugin < Noosfero::Plugin

  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  def self.plugin_name
    "Google Analytics"
  end

  def self.plugin_description
    _("Tracking and web analytics to people and communities")
  end

  def profile_id
    profile = context.send(:profile)
    profile && profile.google_analytics_profile_id
  end

  def head_ending
    return if profile_id.blank?
    expanded_template('tracking-code.html.erb',{:profile_id => profile_id})
  end

  def profile_editor_extras
    return if profile_id.blank?
    expanded_template('profile-editor-extras.html.erb',{:profile_id => profile_id})
  end

end

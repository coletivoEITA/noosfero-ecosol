# workaround for plugin class scope problem
require_dependency 'distribution_plugin/display_helper'

module DistributionPlugin::SessionHelper

  protected

  include DistributionPlugin::DisplayHelper

  def timeline_class(session, status, selected)
    klass = ""
    klass += " session-timeline-passed-item" if session.passed_by?(status)
    klass += " session-timeline-current-item" if session.status == status
    klass += " session-timeline-selected-item" if selected == status
    klass
  end

end

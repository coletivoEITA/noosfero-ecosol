module DistributionPlugin::SessionHelper

  include DistributionPlugin::DistributionDisplayHelper

  def timeline_class(session, status, selected)
    klass = ""
    klass += " session-timeline-passed-item" if session.passed_by?(status)
    klass += " session-timeline-current-item" if session.status == status
    klass += " session-timeline-selected-item" if selected == status
    klass
  end

end

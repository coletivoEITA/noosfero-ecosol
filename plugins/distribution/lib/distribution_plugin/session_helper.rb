module DistributionPlugin::SessionHelper
  def timeline_class(session, status, selected)
    klass = ""
    klass += " distribution-plugin-session-timeline-passed-item" if session.passed_by?(status)
    klass += " distribution-plugin-session-timeline-current-item" if session.status == status
    klass += " distribution-plugin-session-timeline-selected-item" if selected == status
    klass
  end
end

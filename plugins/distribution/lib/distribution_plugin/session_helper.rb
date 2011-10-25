module DistributionPlugin::SessionHelper

  include DistributionPlugin::DistributionDisplayHelper

  def timeline_class(session, status, selected)
    klass = ""
    klass += " timeline-passed-item" if session.passed_by?(status)
    klass += " timeline-current-item" if session.status == status
    klass += " timeline-selected-item" if selected == status
    klass
  end

end

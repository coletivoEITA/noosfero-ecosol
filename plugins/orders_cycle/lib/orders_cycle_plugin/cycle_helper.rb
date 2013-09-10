# workaround for plugin class scope problem
require_dependency 'orders_cycle_plugin/display_helper'

module OrdersCyclePlugin::CycleHelper

  protected

  include OrdersCyclePlugin::DisplayHelper

  def timeline_class cycle, status, selected
    klass = ""
    klass += " cycle-timeline-passed-item" if cycle.passed_by?(status)
    klass += " cycle-timeline-current-item" if cycle.status == status
    klass += " cycle-timeline-selected-item" if selected == status
    klass
  end

end

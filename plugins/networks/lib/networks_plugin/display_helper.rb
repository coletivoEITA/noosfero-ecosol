# workaround for plugins classes scope problem
require_dependency 'suppliers_plugin/display_helper'

module NetworksPlugin::DisplayHelper

  include SuppliersPlugin::TermsHelper
  include SuppliersPlugin::DisplayHelper
  include NetworksPlugin::TranslationHelper

end

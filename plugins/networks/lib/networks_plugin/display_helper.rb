# workaround for plugins classes scope problem
require 'suppliers_plugin/display_helper'

module NetworksPlugin::DisplayHelper

  include TermsHelper
  include SuppliersPlugin::DisplayHelper
  include NetworksPlugin::TranslationHelper

end

require_dependency "#{File.dirname __FILE__}/ext/profile"

class SuppliersPlugin < Noosfero::Plugin

  def self.plugin_name
    "Suppliers"
  end

  def self.plugin_description
    _('Suppliers registry')
  end

  def stylesheet?
    true
  end

  def js_files
    ['suppliers.js']
  end

end

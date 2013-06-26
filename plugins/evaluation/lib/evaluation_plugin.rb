require_dependency "#{File.dirname __FILE__}/ext/enterprise"

class EvaluationPlugin < Noosfero::Plugin

  def self.plugin_name
    "Evaluation"
  end

  def self.plugin_description
    _("A plugin for evaluation of noosfero elements - profiles, articles, exchanges, etc...")
  end

  def stylesheet?
    true
  end

  def js_files
    ['evaluation.js']
  end


end

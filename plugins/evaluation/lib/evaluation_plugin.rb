
class EvaluationPlugin < Noosfero::Plugin

  def self.plugin_name
    "Evaluation"
  end

  def self.plugin_description
    _("User evaluation of network entities - profiles, articles, products, exchanges and others")
  end

  def stylesheet?
    true
  end

  def js_files
    ['evaluation.js'].map{ |j| "javascripts/#{j}" }
  end

end

class EvaluationPluginProfileController < ProfileController

  no_design_blocks

  helper EvaluationPlugin::EvaluationDisplayHelper

  def index
    @evaluations = profile.evaluations
  end

end

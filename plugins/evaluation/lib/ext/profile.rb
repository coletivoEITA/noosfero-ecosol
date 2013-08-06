require_dependency 'profile'

class Profile

  has_many :evaluations, :class_name => "EvaluationPlugin::Evaluation", :foreign_key => :evaluated_id, :dependent => :destroy

  def evaluations_mean
    return if self.evaluations.blank?
    self.evaluations.map{|e| e.score}.instance_eval { reduce(:+) / size.to_f }
  end

end

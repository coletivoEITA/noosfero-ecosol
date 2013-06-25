require_dependency 'enterprise'

class Enterprise

  has_many :evaluations, :class_name => "EvaluationPlugin::Evaluation", :foreign_key => "evaluated_id"
  
  def evaluations_mean
    if !self.evaluations.blank?
      self.evaluations.map{|e| e.score}.instance_eval { reduce(:+) / size.to_f }
    end
      
  end
      
end

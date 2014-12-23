class EvaluationPlugin::Evaluation < ActiveRecord::Base

  attr_accessible *self.column_names
  attr_accessible :object, :evaluator, :evaluated

  belongs_to :object, polymorphic: true
  belongs_to :evaluator, class_name: "Profile"
  belongs_to :evaluated, class_name: "Profile"

  validates_presence_of :object
  validates_presence_of :evaluator
  validates_presence_of :evaluated

  ResultMessage = {
    0 => _("Yes"),
    1 => _("Parcially (we did our part, the other didn't)"),
    2 => _("Parcially (the other side did their part, we didn't)"),
    3 => _("No"),
  }

  def result_message
    _ ResultMessage[self.result.to_i]
  end

end

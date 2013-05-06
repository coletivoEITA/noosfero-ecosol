class ChangeEvaluationToObjectInEvaluation < ActiveRecord::Migration
  def self.up
    rename_column :evaluation_plugin_evaluations, :evaluation_id, :object_id
    rename_column :evaluation_plugin_evaluations, :evaluation_type, :object_type
  end

  def self.down
  end
end

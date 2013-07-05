class ChangeEvaluationPluginEvaluationAddResult < ActiveRecord::Migration
  def self.up
    add_column :evaluation_plugin_evaluations, :result, :string
  end

  def self.down
    remove_column :evaluation_plugin_evaluations, :result
  end
end

class CreateEvaluationPluginEvaluations < ActiveRecord::Migration
  def self.up
    create_table :evaluation_plugin_evaluations do |t|
      t.string :evaluation_type
      t.integer :evaluation_id
      t.decimal :score
      t.text :text
      t.integer :evaluator_id
      t.integer :evaluated_id

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluation_plugin_evaluations
  end
end

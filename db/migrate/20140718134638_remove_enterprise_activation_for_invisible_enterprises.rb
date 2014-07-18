class RemoveEnterpriseActivationForInvisibleEnterprises < ActiveRecord::Migration

  def self.up
    Enterprise.invisible.find_each do |enterprise|
      next unless enterprise.activation_task
      enterprise.activation_task.destroy
    end
  end

end

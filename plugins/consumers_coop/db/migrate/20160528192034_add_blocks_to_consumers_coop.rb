class AddBlocksToConsumersCoop < ActiveRecord::Migration
  def up
    Community.find_each(batch_size: 50) do |profile|
      profile.consumers_coop_add_own_blocks if profile.consumers_coop_settings.enabled
    end
  end
  def down
    Community.find_each(batch_size: 50) do |profile|
      profile.consumers_coop_remove_own_blocks if profile.consumers_coop_settings.enabled
    end
  end
end

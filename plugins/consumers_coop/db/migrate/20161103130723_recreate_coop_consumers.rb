class RecreateCoopConsumers < ActiveRecord::Migration
  def up
    Community.where("data like '%consumers_coop_plugin%'").select{ |c| c.consumers_coop_settings.enabled }.each{ |c| c.consumers.delete_all; c.members.each{ |m| c.add_consumer m } }
  end
  def down
  end
end

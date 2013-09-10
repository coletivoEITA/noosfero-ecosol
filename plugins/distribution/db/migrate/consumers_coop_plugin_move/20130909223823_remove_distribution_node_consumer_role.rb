class RemoveDistributionNodeConsumerRole < ActiveRecord::Migration
  def self.up
    role = Role.first :conditions => {:key => 'distribution_node_consumer'}
    ActiveRecord::Base.connection.execute "DELETE FROM role_assignments WHERE role_id = #{role.id}"
    ActiveRecord::Base.connection.execute "DELETE FROM roles WHERE id = #{role.id}"
  end

  def self.down
    say "this migration can't be reverted"
  end
end

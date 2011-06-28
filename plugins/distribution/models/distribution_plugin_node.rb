class DistributionPluginNode < ActiveRecord::Base
  belongs_to :profile, :dependent => :destroy
  has_many :products, :class_name => 'DistributionPluginProduct', :foreign_key => 'node_id', :as => 'node'
  validates_presence_of   :profile
  validates_inclusion_of  :role, :in => ['supplier','collective', 'consumer']

  module Roles
    def self.consumer(env_id)
      find_role('consumer', env_id)
    end

    private
    def self.find_role(name, env_id)
      ::Role.find_by_key_and_environment_id("distribution_node_#{name}", env_id)
    end
  end

  acts_as_accessor
  acts_as_accessible
  named_scope :consumers_of, lambda { |supplier| { :select => 'DISTINCT distribution_nodes.*', :joins => 'LEFT JOIN role_assignments ON role_assignments.resource_id = distribution_nodes.id', :conditions => ['role_assignments.accessor_type = ? AND role_assignments.accessor_id = ?', supplier.class.base_class.name, supplier.id ] } }
  named_scope :suppliers_of, lambda { |consumer| { :select => 'DISTINCT distribution_nodes.*', :joins => 'LEFT JOIN role_assignments ON role_assignments.accessor_id = distribution_nodes.id', :conditions => ['role_assignments.resource_type = ? AND role_assignments.resource_id = ?', consumer.class.base_class.name, consumer.id ] } }
  def consumers
    DistributionPluginNode.consumers_of(self)
  end
  def suppliers
    DistributionPluginNode.suppliers_of(self)
  end

  before_create :check_roles
  def check_roles
    Role.create!(
      :key => 'distribution_node_consumer',
      :name => N_('Consumer'),
      :environment => profile.environment,
      :permissions => [
        'order_product',
      ]
    ) if profile and !DistributionPluginNode::Roles.consumer(profile.environment)
  end

  def add_consumer(consumer)
    consumer.affiliate(self, DistributionPluginNode::Roles.consumer(self.profile.environment))
  end
  def remove_consumer(consumer)
    consumer.disaffiliate(self, DistributionPluginNode::Roles.consumer(self.profile.environment))
  end

  def blocks_to_expire_cache
    []
  end
  def cache_keys(params = {})
    []
  end
end

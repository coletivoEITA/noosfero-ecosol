require_dependency 'profile'

# FIXME move to core
class Profile

  def has_admin? person
    return unless person
    person.has_permission? 'edit_profile', self
  end

end

class Profile

  has_many :orders, :class_name => 'OrdersPlugin::Order', :order => 'updated_at DESC'
  alias_method :sales, :orders

  has_many :parcels, :class_name => 'OrdersPlugin::Order', :foreign_key => :consumer_id, :order => 'updated_at DESC'
  alias_method :purchases, :parcels

  has_many :ordered_items, :through => :orders, :source => :items, :order => 'name ASC'

  def self.create_orders_manager_role env_id
    env = Environment.find env_id
    Role.create! :environment => env,
      :key => "profile_orders_manager",
      :name => I18n.t("orders_plugin.lib.ext.profile.orders_manager"),
      :permissions => [
        'manage_orders',
      ]
  end

  def orders_managers
    self.members_by_role Profile::Roles.orders_manager(environment.id)
  end

  PERMISSIONS['Profile']['manage_orders'] = N_('Manage orders')
  module Roles
    def self.orders_manager env_id
      role = find_role 'orders_manager', env_id
      role ||= Profile.create_orders_manager_role env_id
      role
    end

    class << self
      def all_roles_with_orders_manager env_id
        roles = all_roles_without_orders_manager env_id
        if not roles.find{ |r| r.key == 'profile_orders_manager' }
          Profile.create_orders_manager_role env_id
          roles = all_roles_without_orders_manager env_id
        end

        roles
      end
      alias all_roles_without_orders_manager all_roles
      alias all_roles all_roles_with_orders_manager
    end
  end

end

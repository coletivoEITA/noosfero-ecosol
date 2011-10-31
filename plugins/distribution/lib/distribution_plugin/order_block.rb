class DistributionPlugin::OrderBlock < Block

 def self.short_description
   _('Orders for consumers')
 end

 def self.description
   _('Distribution orders for consumers')
 end

 def self.available_for(profile)
   node = DistributionPluginNode.find_by_profile_id owner.id
   !node.blank? && !node.consumer?
 end

 def node
   @node ||= DistributionPluginNode.find_by_profile_id owner.id
 end

 def default_title
   _('Orders')
 end

 def help
   _('Offer cycles for you customers to make offers')
 end

 def content
   n = node
   block = self

   lambda do
     consumer = DistributionPluginNode.find_by_profile_id current_user.person.id
     @controller.append_view_path DistributionPlugin.view_path
     extend DistributionPlugin::DistributionDisplayHelper
     render :file => 'blocks/distribution_plugin_order', :locals => { :block => block, :node => n, :consumer => consumer }
   end
 end

end


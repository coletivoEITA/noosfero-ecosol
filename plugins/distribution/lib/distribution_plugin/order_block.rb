class DistributionPlugin::OrderBlock < Block

 def self.short_description
   _("Orders' cycles")
 end

 def self.description
   _("Distribution orders' cycles for members")
 end

 def self.available_for(profile)
   node = DistributionPluginNode.find_or_create owner
   !node.blank? && !node.consumer?
 end

 def node
   @node ||= DistributionPluginNode.find_or_create owner
 end

 def default_title
   self.class.short_description
 end

 def help
   _('Offer cycles for you members to make offers')
 end

 def content
   n = node
   block = self

   lambda do
     consumer = current_user ? DistributionPluginNode.find_or_create(current_user.person) : nil
     @controller.append_view_path DistributionPlugin.view_path
     extend DistributionPlugin::DistributionDisplayHelper
     render :file => 'blocks/distribution_plugin_order', :locals => { :block => block, :node => n, :consumer => consumer }
   end
 end

  def cacheable?
    false
  end

end


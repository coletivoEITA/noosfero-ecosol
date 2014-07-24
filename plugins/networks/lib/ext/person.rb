require_dependency 'person'

class Person

  def may_join_network? network
   self.enterprises.visible.present? and self.enterprises.visible.select do |e|
     e.network != network and NetworksPlugin::AssociateEnterprise.where(:target_id => network.id, :requestor_id => e.id).first.blank?
   end.present?
  end

end

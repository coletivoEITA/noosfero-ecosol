Given /^the consumers coop is (enabled|disabled) on "([^""]*)"$/ do |status, name|
  status = status == 'enabled'
  coop = Community.find_by(name: name) || Enterprise[name]
  coop.consumers_coop_settings.enabled = status
  if status
    coop.consumers_coop_enable
  else
    coop.consumers_coop_disable
  end
  coop.save!
end

Given /^"([^""]*)" is a supplier of "([^""]*)"$/ do |supplier, consumer|
  supplier = Enterprise.find_by(name: supplier) || Enterprise[supplier]
  consumer = Profile.find_by(name: consumer) || Profile[consumer]
  consumer.add_supplier supplier
end


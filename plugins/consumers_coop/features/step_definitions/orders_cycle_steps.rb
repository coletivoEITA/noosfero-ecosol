Given /^the consumers coop is (enabled|disabled) on "([^""]*)"$/ do |status, name|
  status = status == 'enabled'
  coop   = Community.find_by(name: name) || Enterprise[name]
  if status
    coop.consumers_coop_enable
  else
    coop.consumers_coop_disable
  end
  coop.consumers_coop_settings.enabled = status
  coop.theme = 'distribution'
  coop.save!
end

Given /^"([^""]*)" is a supplier of "([^""]*)"$/ do |supplier, consumer|
  supplier = Enterprise.find_by(name: supplier) || Enterprise[supplier]
  consumer = Profile.find_by(name: consumer) || Profile[consumer]
  consumer.add_supplier supplier
  Delayed::Job.work_off
end

When /^I add cycle product "([^"]*)"$/ do |product|
  evaluate_script("$('.order-cycle-product div:contains(#{product})')")['0'].click
end

When /^I open the order with "([^"]*)"$/ do |text|
  evaluate_script("$('.order span:contains(#{text})')")['0'].click
end

When /^I fill the daterangepicker "([^"]*)" with "([^"]*)"$/ do |name, date|
  execute_script("$('input[name=\"#{name}\"]').val('#{date}')")
end

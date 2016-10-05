require_dependency 'community'

class Community

  attr_accessible :payment_method_ids

  def payment_methods_list
    self.payment_methods.each_with_object({}){|pm,h| h[pm.slug] = pm.name }
  end
end


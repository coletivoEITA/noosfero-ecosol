class DistributionPluginDistributedProduct < DistributionPluginProduct

  def supplier_products
    from_products
  end

  alias_method :default_name_setting, :default_name
  def default_name
    dummy? ? nil : default_name_setting
  end
  alias_method :default_description_setting, :default_description
  def default_description
    dummy? ? nil : default_description_setting
  end

  def price_with_margins
    ret = price_without_margins
    return ret if ret.blank?

    if margin_percentage
      ret += (margin_percentage/100)*ret
    elsif node.margin_percentage
      ret += (node.margin_percentage/100)*ret
    end
    if margin_fixed
      ret += margin_fixed
    elsif node.margin_fixed
      ret += node.margin_fixed
    end

    ret
  end

end

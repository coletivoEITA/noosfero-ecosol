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

  def price
    price_with_margins = price_without_margins
    return price_with_margins if price_with_margins.blank?

    if margin_percentage
      price_with_margins += (margin_percentage/100)*price_with_margins
    elsif node.margin_percentage
      price_with_margins += (node.margin_percentage/100)*price_with_margins
    end
    if margin_fixed
      price_with_margins += margin_fixed
    elsif node.margin_fixed
      price_with_margins += node.margin_fixed
    end

    price_with_margins
  end

end

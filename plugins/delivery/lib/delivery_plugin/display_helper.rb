module DeliveryPlugin::DisplayHelper

  def input_group_addon unit
    yield
  end unless defined? ResponsivePlugin

  def supplier_delivery_options options = {}
    selected = options[:selected]
    methods = options[:methods] || profile.delivery_methods

    options = methods.map do |method|
      cost = if method.fixed_cost.present? and method.fixed_cost > 0 then method.fixed_cost_as_currency else nil end
      text = if cost.present? then "#{method.name} (#{cost})" else method.name end

      content_tag :option, text, value: method.id,
        data: {label: method.name, type: method.delivery_type, instructions: h(method.description.to_s)},
        selected: if method.id == selected then 'selected' else nil end
    end.join
  end

  def supplier_delivery_selected_method options = {}
    selected = options[:selected]
    methods = options[:methods] || profile.delivery_methods

    method_text = ""
    methods.each do |method|
      cost = if method.fixed_cost.present? and method.fixed_cost > 0 then method.fixed_cost_as_currency else nil end
      text = if cost.present? then "#{method.name} (#{cost})" else method.name end
      if method.id == selected
        method_text = content_tag 'div', text, class: 'method_name'
        method_text += content_tag 'div', method.description, class: 'method_description'
        break
      end
    end
    method_text
  end

  def consumer_delivery_field_value order, field
    # BLACK OR WHITE: do not mix existing delivery data with user's location
    if order.consumer_delivery_data.present?
      order.consumer_delivery_data[field]
    elsif user
      user.send field
    end
  end

  def delivery_context
    @delivery_context || 'delivery_plugin/admin_method'
  end

end

module OrdersPlugin::DisplayHelper

  protected

  # come on, you can't replace a rails api method (button_to_function was)!
  def submit_to_function name, function, html_options={}
    content_tag 'input', '', html_options.merge(:onclick => function, :type => 'submit', :value => name)
  end

end

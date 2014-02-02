module OrdersPlugin::DisplayHelper

  protected

  include OrdersPlugin::TranslationHelper
  include OrdersPlugin::PriceHelper
  include OrdersPlugin::DateHelper
  include OrdersPlugin::TableHelper
  include OrdersPlugin::JavascriptHelper

  # come on, you can't replace a rails api method (button_to_function was)!
  def submit_to_function name, function, html_options={}
    content_tag 'input', '', html_options.merge(:onclick => function, :type => 'submit', :value => name)
  end

  def excerpt_ending text, length, omission = '...'
    return if text.blank?
    content_tag 'span', truncate(text, :length => length+omission.length, :omission => omission), :title => text
  end

end

# encoding: UTF-8
=begin
require_dependency 'plugins_helper'

module PluginsHelper

  def plugins_catalog_search_extras_begin
    return super unless theme_responsive?

    @plugins.dispatch(:catalog_search_extras_begin).map do |content|
      htmls = instance_exec(&content)
      htmls.inject ('') {|acc,n| acc += n[:content]  }
    end.join
  end

  def plugins_catalog_search_extras_end
    return super unless theme_responsive?

    @plugins.dispatch(:catalog_search_extras_end).map do |content|
      htmls = instance_exec(&content)
      htmls.inject ('') {|acc,n| acc += n[:content]  }
    end.join
  end

end
=end
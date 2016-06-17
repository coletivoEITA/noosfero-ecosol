class SuppliersPlugin::ConsumerController < MyProfileController

  include SuppliersPlugin::TranslationHelper

  protect 'edit_profile', :profile

  helper SuppliersPlugin::TranslationHelper
  helper SuppliersPlugin::DisplayHelper

  def index
  end

  protected

  extend HMVC::ClassMethods
  hmvc SuppliersPlugin

    # inherit routes from core skipping use_relative_controller!
  def url_for options
    options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
    super options
  end
  helper_method :url_for
end

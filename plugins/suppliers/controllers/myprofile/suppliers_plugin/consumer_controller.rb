class SuppliersPlugin::ConsumerController < MyProfileController

  include SuppliersPlugin::TranslationHelper

  protect 'edit_profile', :profile

  helper SuppliersPlugin::TranslationHelper
  helper SuppliersPlugin::DisplayHelper

  def index
    @tasks_count = Task.to(profile).pending.without_spam.select{|i| user.has_permission?(i.permission, profile)}.count
  end

  def purchases
    @sales = OrdersCyclePlugin::Sale.where(consumer_id: params[:consumer_id]).joins(:cycles).last(10)

    respond_to do |format|
      format.json {render json: @sales}
    end
  end

  def update
    @consumer = SuppliersPlugin::Consumer.find params[:id]
    attrs = params[:consumer].except :id
    ret = @consumer.update! attrs
    render text: ret.to_s
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

class SuppliersPlugin::ConsumerController < MyProfileController

  include SuppliersPlugin::TranslationHelper

  protect 'edit_profile', :profile

  helper SuppliersPlugin::TranslationHelper
  helper SuppliersPlugin::DisplayHelper

  serialization_scope :view_context

  def index
    @tasks_count = Task.to(profile).pending.without_spam.select{|i| user.has_permission?(i.permission, profile)}.count
    @role = Role.where(key: 'profile_member').first
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

  def add_consumers
    people = [Person.find(params[:consumers].split(','))].flatten
    role = Role.where(key: 'profile_member').first
    to_add = people - profile.members_by_role(role)

    begin
      to_add.each { |person| profile.affiliate(person, role) }
    rescue Exception => ex
      logger.info ex
    end

    consumers = profile.consumers.where(consumer_id: params[:consumers].split(','))
    render json: consumers
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

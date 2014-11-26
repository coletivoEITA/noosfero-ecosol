module NeedsProfile

  module ClassMethods
    def needs_profile
      self.cattr_accessor :profile_needed
      self.profile_needed = true
      before_filter :load_profile
    end
  end

  def self.included(including)
    including.send(:extend, NeedsProfile::ClassMethods)
  end

  def boxes_holder
    profile || environment # prefers profile, but defaults to environment
  end

  def profile
    @profile
  end

  protected

  def load_profile
    @profile ||= environment.profiles.find_by_identifier(params[:profile])
    if @profile
      # this is needed for facebook applications that can only have one domain
      return

      profile_hostname = @profile.hostname
      if profile_hostname and request.host == @environment.default_hostname
        redirect_to params.merge(@profile.send :url_options)
      end
    else
      render_not_found
    end
  end

end

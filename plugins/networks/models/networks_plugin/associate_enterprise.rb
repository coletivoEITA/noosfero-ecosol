class NetworksPlugin::AssociateEnterprise < Task

  alias :network :target
  alias :network= :target=

  alias :enterprise :requestor
  alias :enterprise= :requestor=

  validates_presence_of :network
  validates_presence_of :enterprise

  before_save :workaround_target_type

  include NetworksPlugin::TranslationHelper

  def title
    t('models.associate_enterprise.title')
  end

  def linked_subject
    {:text => self.network.short_name, :url => self.network.url}
  end

  def information
    {:message => t('models.associate_enterprise.information')}
  end

  def icon
    src = if self.network.image then self.network.image.public_filename :minor else '/images/icons-app/enterprise-minor.png' end
    {:type => :defined_image, :src => src, :name => self.network.name}
  end

  def accept_details
    true
  end
  def reject_details
    true
  end

  def perform
    self.network.add_enterprise self.enterprise
  end

  def target_notification_description
    t('models.associate_enterprise.task_notification_message') % {
      :enterprise => self.enterprise.short_name, :network => self.network.short_name,
    }
  end

  def task_created_message
    task = self
    lambda do
      render :partial => 'tasks/networks_plugin/associate_enterprise/task_created', :locals => {:task => task}
    end
  end

  def target_notification_message
    t('models.associate_enterprise.task_notification_message') % {
      :enterprise => self.enterprise.short_name, :network => self.network.short_name,
      :linked_subject => self.linked_subject,
    }
  end

  def task_finished_message
    t('models.associate_enterprise.task_finished_message') % {
      :enterprise => self.enterprise.short_name, :network => self.network.short_name,
      :linked_subject => self.linked_subject,
    }
  end

  def task_cancelled_message
    message = t('models.associate_enterprise.task_cancelled_message') % {
      :enterprise => self.enterprise.short_name, :network => self.network.short_name,
      :linked_subject => self.linked_subject,
    }
    return if reject_explanation.blank?
    message += " " + _("Here is the reject explanation left by the administrator:\n\n%{reject_explanation}") % {:reject_explanation => self.reject_explanation}
  end

  protected

  def workaround_target_type
    self['target_type'] = 'Profile'
  end

end

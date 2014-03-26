class EnvironmentStatisticsBlock < Block

  def self.description
    _('Environment stastistics')
  end

  def default_title
    _('Statistics for %s') % owner.name
  end

  def help
    _('This block presents some statistics about your environment.')
  end

  def content(args={})
    block = self
    users = owner.people.visible.count
    communities = owner.communities.visible.count
    enterprises = owner.enterprises.visible.enabled.count
    products = owner.products.enabled.public.count

    lambda do
      render :file => 'blocks/environment_statistics', :locals => {:block => block,
        :users => users, :communities => communities,
        :enterprises => enterprises, :products => products,
      }
    end
  end

end

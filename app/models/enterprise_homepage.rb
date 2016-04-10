class EnterpriseHomepage < Article

  def self.type_name
    _('Homepage')
  end

  def self.short_description
    _("Presentation and enterprise's catalog")
  end

  def self.description
    _("Put a text and show the enterprise's catalog below.")
  end

  def self.refuse_blocks
    true
  end

  def name
    if self['name'].blank? then _('Homepage') else self['name'] end
  end

  def to_html(options = {})
    enterprise_homepage = self
    lambda do
      extend EnterpriseHomepageHelper
      extend CatalogHelper
      catalog_load_index :page => 1, :show_categories => false
      render 'content_viewer/enterprise_homepage', :enterprise_homepage => enterprise_homepage, :enterprise => enterprise_homepage.profile
    end
  end

  # disable cache because of products
  def cache_key params = {}, the_profile = nil, language = 'en'
    rand
  end

  def can_display_hits?
    false
  end

  def can_display_media_panel?
    true
  end

end

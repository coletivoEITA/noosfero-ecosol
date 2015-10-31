require 'white_list_filter'

class TinyMceArticle < TextArticle

  def self.short_description
    _('Article')
  end

  def self.description
    _('Add a new text article.')
  end

  def self.refuse_blocks
    true
  end

  xss_terminate :only => [  ]

  xss_terminate :only => [ :name, :abstract, :body ], :with => 'white_list', :on => 'validation'

  include WhiteListFilter
  filter_iframes :abstract, :body
  def iframe_whitelist
    profile && profile.environment && profile.environment.trusted_sites_for_iframe
  end

  def notifiable?
    true
  end

  def tiny_mce?
    true
  end

  def can_display_media_panel?
    true
  end

end

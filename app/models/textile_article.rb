class TextileArticle < TextArticle

  def self.short_description
    _('Text article for people with visual impairement')
  end

  def self.description
    _('Textile format.')
  end

  def to_html(options ={})
    convert_to_html(body)
  end

  def lead
    if abstract.blank?
      super
    else
      convert_to_html(abstract)
    end
  end

  def notifiable?
    true
  end

  def can_display_media_panel?
    true
  end

  protected

  def convert_to_html(textile)
    @@sanitizer ||= HTML::WhiteListSanitizer.new
    converter = RedCloth.new(textile|| '')
    converter.hard_breaks = false
    @@sanitizer.sanitize(converter.to_html)
  end

end

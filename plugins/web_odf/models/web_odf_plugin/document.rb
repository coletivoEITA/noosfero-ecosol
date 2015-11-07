class WebODFPlugin::Document < Article

  def self.icon_name article = nil
    'web-odf-document'
  end

  def self.short_description
    I18n.t'web_odf_plugin.models.document.short_description'
  end

  def self.description
    I18n.t'web_odf_plugin.models.document.description'
  end

  def self.refuse_blocks
    true
  end

  # #body method override will crash due to binary on db adapter, so use #odf
  def odf
    Base64.decode64 self[:body]
  end
  def body= value
    self[:body] = Base64.encode64 value.split(',').map(&:to_i).pack('C*')
  end

  def filename
    "#{self.name}.odt"
  end

  def to_html options = {}
    lambda do
      render template: 'content_viewer/web_odf_plugin/document'
    end
  end

end


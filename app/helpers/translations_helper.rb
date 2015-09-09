module TranslationsHelper

  def js_translations_include options={}
    if plugin = options[:plugin]
      javascript_include_tag "i18n/#{plugin}/#{I18n.locale}"
    else
      javascript_include_tag "i18n/#{I18n.locale}"
    end
  end

end

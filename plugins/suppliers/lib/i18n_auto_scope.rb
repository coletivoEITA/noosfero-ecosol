
module I18nAutoScope

  DefaultScope = 'suppliers_plugin'

  def default_i18n_scope
    DefaultScope
  end

  # should be replaced on controller (e.g. controller)
  def i18n_scope
    default_i18n_scope
  end

  protected

  def self.included base
    base.send :define_method, :translate, I18n.method(:t).to_proc unless base.respond_to? :translate

    base.alias_method_chain :translate, :auto_scope
    base.send :alias_method, :t, :translate
  end

  def translate_with_auto_scope key, options = {}
    options[:raise] = true
    options[:scope] ||= i18n_scope

    translation = self.translate_without_auto_scope key, options rescue nil
    unless translation
      options[:scope] = default_i18n_scope
      translation = self.translate_without_auto_scope key, options rescue nil
    end

    translation
  end

end

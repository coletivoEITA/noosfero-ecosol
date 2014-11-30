module CurrencyHelper

  extend ActionView::Helpers::NumberHelper

  def self.parse_localized_number number
    return number if number.blank?
    number = number.to_s
    number.gsub(I18n.t("number.currency.format.unit"), '')
      .gsub(I18n.t("number.currency.format.delimiter"), '')
      .gsub(I18n.t("number.currency.format.separator"), '.')
      .to_f
  end

  def self.parse_currency currency
    self.parse_localized_number currency
  end

  def self.localized_number number
    number_with_delimiter number.to_f
  end

  def self.number_as_currency_number number
    string = number_to_currency number, unit: ''
    string.gsub! ' ', '' if string
    string
  end

  def self.number_as_currency number
    number_to_currency number
  end

  module ClassMethods

    def has_number_with_locale attr
      self.send :define_method, "#{attr}_with_locale=" do |value|
        value = CurrencyHelper.parse_localized_number value if value.is_a? String
        self.send "#{attr}_without_locale=", value
      end
      alias_method_chain "#{attr}=", :locale rescue nil # rescue if method don't have a setter

      self.send :define_method, "#{attr}_localized" do |*args, &block|
        number = self.send attr, *args, &block
        CurrencyHelper.localized_number number
      end
    end

    def has_currency attr
      self.has_number_with_locale attr

      self.send :define_method, "#{attr}_as_currency" do |*args, &block|
        number = self.send attr, *args, &block
        CurrencyHelper.number_as_currency number
      end
      self.send :define_method, "#{attr}_as_currency_number" do |*args, &block|
        number = self.send attr, *args, &block
        CurrencyHelper.number_as_currency_number number
      end
    end

  end

  module InstanceMethods

  end

end

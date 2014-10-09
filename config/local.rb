Noosfero.default_locale = 'pt'
FastGettext.locale = Noosfero.default_locale
FastGettext.default_locale = Noosfero.default_locale
I18n.locale = Noosfero.default_locale
I18n.default_locale = Noosfero.default_locale

# don't work with delayed job
#Time.zone = 'America/Sao_Paulo'

require 'noosfero/terminology'
class CirandasTerminology < Noosfero::Terminology::Custom
  def initialize
    super({
      'Enterprises' => 'Empreendimentos de Economia Solidária',
      'Enterprises in "%s"' => 'Empreendimentos de Economia Solidária em "%s"',
    })
  end
end


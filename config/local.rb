Noosfero.default_locale = 'pt'
FastGettext.locale = Noosfero.default_locale
I18n.locale = Noosfero.default_locale

require 'noosfero/terminology'
class CirandasTerminology < Noosfero::Terminology::Custom
  def initialize
    super({
      'Enterprises' => 'Empreendimentos de Economia Solidária',
      'Enterprises in "%s"' => 'Empreendimentos de Economia Solidária em "%s"',
    })
  end
end

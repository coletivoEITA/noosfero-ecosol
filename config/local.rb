Noosfero.default_locale = 'pt'

require 'noosfero/terminology'
class CirandasTerminology < Noosfero::Terminology::Custom
  def initialize
    super({
      'Enterprises' => 'Empreendimentos de Economia Solidária',
      'Enterprises in "%s"' => 'Empreendimentos de Economia Solidária em "%s"',
    })
  end
end

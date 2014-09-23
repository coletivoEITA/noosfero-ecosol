#see https://github.com/guard/guard/wiki/Use-Guard-programmatically-cookbook

fork do
  if __FILE__ == '(irb)'
  end

  Guard.guards 'sass'
  Guard.start :no_interactions => true
end

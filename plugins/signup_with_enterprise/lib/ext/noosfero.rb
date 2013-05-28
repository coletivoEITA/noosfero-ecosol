require_dependency 'noosfero'

module Noosfero
  # see also convToValidIdentifier at application.js
  def self.convert_to_identifier(string, sep='-')
    str = string.downcase
    str.gsub!( /@.*$/,     ""  )
    str.gsub!( /á|à|ã|â/,  "a" )
    str.gsub!( /é|ê/,      "e" )
    str.gsub!( /í/,        "i" )
    str.gsub!( /ó|ô|õ|ö/,  "o" )
    str.gsub!( /ú|ũ|ü/,    "u" )
    str.gsub!( /ñ/,        "n" )
    str.gsub!( /ç/,        "c" )
    str.gsub!( /[^-_a-z0-9.]+/, sep )
    str
  end
end

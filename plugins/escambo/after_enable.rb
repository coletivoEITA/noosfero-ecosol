deps = [:sniffer, :cms_learning, :exchange, :evaluation]

puts "Now you can enable dependencies:"
deps.each do |plugin|
  puts "script/noosfero-plugins enable #{plugin}"
end

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# when to compile on start
environment = ENV['RAILS_ENV']
all_on_start = environment == 'production'

# core and plugins
sass_locations = Dir.glob("public/stylesheets") +
  Dir.glob("{,base}plugins/*/public/{,stylesheets}") 
sass_locations.each do |location|
  guard 'sass', :input => location, :output => location, :all_on_start => all_on_start
end

# themes
themes_path = "public/designs/themes"
load_paths = ['.'] + Dir.glob("#{themes_path}/cirandas{,/stylesheets}")
sass_locations = Dir.glob("#{themes_path}/*{,/stylesheets}")
sass_locations.map!{ |l| l = "#{File.dirname l}/#{File.readlink l}" while File.symlink? l; l }
sass_locations.each do |location|
  guard 'sass', :input => location, :output => location, :all_on_start => all_on_start, :load_paths => load_paths
end


# Copyright 2006 Pascal Belloncle
puts "Installing: " + File.join(File.dirname(__FILE__), 'config', 'textlinkads.yml')
puts " to " + File.join(Rails.root, 'config') + "\n"
unless File.exist?(File.join(Rails.root, 'config'))
  puts "config dir does not exist"
end
puts "dir name: "+File.dirname(__FILE__)
puts "config file name"
unless File.exist?(File.join(File.dirname(__FILE__), 'config', 'textlinkads.yml'))
  puts "textlinkads.yml exist"
end
unless File.exist?(File.join(File.dirname(__FILE__), '..', '..', '..', 'config'))
  puts "relative config dir does not exist"
end
FileUtils.cp File.join(File.dirname(__FILE__), 'config', 'textlinkads.yml'), File.join(File.dirname(__FILE__), '..', '..', '..', 'config')
puts IO.read(File.join(File.dirname(__FILE__), 'README'))
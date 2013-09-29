require "bundler/gem_tasks"

namespace :bin do
  task :setup do
    binaries = Dir.entries("./binaries").reject { |f| [".", ".."].include?(f) }

    binaries.each do |binary|
      contents = <<-RUBY
require 'pathname'
pn = Pathname.new(__FILE__)
opts = ARGV.join(" ")
puts `\#{pn.dirname}/../binaries/\#{pn.basename} \#{opts}`
      RUBY

      binary_path = "./bin/#{binary}"
      File.open(binary_path, 'w') { |file| file.write(contents) }
      FileUtils.chmod('a+x', [binary_path])
      puts "#{binary_path} generated"
    end
  end
end
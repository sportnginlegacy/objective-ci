require "bundler/gem_tasks"

namespace :bin do
  task :setup do
      binaries_location = "./externals"
      %W(sloccount oclint).each do |executable_dir|
        executable_dir_path = "#{binaries_location}/#{executable_dir}"
        binaries = Dir.entries(executable_dir_path).select {|f| !File.directory? f}
        binaries.each do |binary|
        contents = <<-RUBY
  require 'pathname'
  pn = Pathname.new(__FILE__)
  opts = ARGV.join(" ")
  puts `"\#{pn.dirname}/../#{executable_dir_path}/\#{pn.basename}" \#{opts}`
        RUBY

        gem_binary_path = "./bin/#{binary}"
        File.open(gem_binary_path, 'w') { |file| file.write(contents) }
        FileUtils.chmod('a+x', [gem_binary_path])
        puts "#{gem_binary_path} generated"
      end
    end
  end
end

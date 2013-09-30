require 'bundler/setup'
require 'nokogiri'

module ObjectiveCi
    class CiTasks

    attr_accessor :exclusions

    LINT_DESTINATION = "lint.xml"
    DUPLICATION_DESTINATION = "duplication.xml"
    LINE_COUNT_DESTINATION = "line-count.sc"    

    def initialize
      @exclusions = ["vendor"]
      if using_pods?
        @exclusions << "Pods"
        `pod install`
      end
    end

    def build(opts={})
      lint(opts)
      lines_of_code(opts)
      test_suite(opts)
      duplicate_code_detection(opts)
    end

    def lint(opts={})
      requires_at_least_one_option(opts, :workspace, :project)
      requires_options(opts, :scheme)
      opts[:configuration] ||= "Release"

      sliced_opts = opts.select { |k, v| [:scheme, :workspace, :project, :configuration].include?(k) }
      xcodebuild_opts_string = sliced_opts.reduce("") { |str, (k, v)| str += " -#{k} #{v}" }
      xcodebuild_opts_string += " ONLY_ACTIVE_ARCH=NO clean build"

      call_binary("xcodebuild", xcodebuild_opts_string, "| tee xcodebuild.log", opts)
      # oclint-xcodebuild will fail if we don't exclude Pods (absolute path)
      pods_dir = "#{Dir.pwd}/Pods"
      call_binary("oclint-xcodebuild", "-e \"#{pods_dir}\"", "", opts)
      ocjcd_opts_string = "#{exclusion_options_list("-e")} -- -report-type=pmd -o=#{LINT_DESTINATION}"
      call_binary("oclint-json-compilation-database", ocjcd_opts_string, "", opts)
    end

    def test_suite(opts={})
      requires_at_least_one_option(opts, :workspace, :project)
      requires_options(opts ,:scheme)
      if !opts[:xcodebuild_override] && xcode_version < 5.0
        puts_red "WARNING: Xcode version #{xcode_version} is less than 5.0, and tests will likely not run"
      end
      
      sliced_opts = opts.select { |k, v| [:scheme, :workspace, :project].include?(k) }
      xcodebuild_opts_string = sliced_opts.reduce("") { |str, (k, v)| str += " -#{k} #{v}" }

      xcodebuild_opts_string += " -destination name=iPad -destination-timeout=10 ONLY_ACTIVE_ARCH=NO test"
      call_binary("xcodebuild", xcodebuild_opts_string, ">&1 | ocunit2junit", opts)
    end

    def lines_of_code(opts={})
      call_binary("sloccount",
                  "--duplicates --wide --details .",
                  "| grep -v #{exclusion_options_list("-e")} > #{LINE_COUNT_DESTINATION}", 
                  opts)
    end

    def duplicate_code_detection(opts={})
      opts[:minimum_tokens] ||= 100
      call_binary("pmd-cpd-objc",
                  "--minimum-tokens #{opts[:minimum_tokens]}",
                  "> #{DUPLICATION_DESTINATION}", 
                  opts)
      pmd_exclude
    end

    private
    def exclusion_options_list(option_flag)
      if exclusions.empty?
        ''
      else
        wrapped_exclusions = exclusions.map { |e| "\"#{e}\"" }
        "#{option_flag} #{wrapped_exclusions.join(" #{option_flag} ")}"
      end
    end

    private
    def using_pods?
      File.exists?("Podfile")
    end

    private
    def call_binary(binary, cl_options, tail, opts={})
      extra_options = opts["#{binary}_options".to_sym]
      override_options = opts["#{binary}_override".to_sym]
      cl_options = override_options ? extra_options : "#{cl_options} #{extra_options}"
      command = "#{binary} #{cl_options} #{tail}"
      puts command
      `#{command}`
    end

    private 
    def requires_options(opts, *keys)
      keys.each do |k|
        raise "option #{k} is required." unless opts.has_key?(k)
      end
    end

    private
    def requires_at_least_one_option(opts, *keys)
      if (opts.keys && keys).empty?
        raise "at least one of the options #{keys.join(", ")} is required"
      end
    end

    private
    def pmd_exclude
      # Unfortunately, pmd doesn't seem to provide any nice out-of-the-box way for excluding files from the results.
      absolute_exclusions = exclusions.map { |e| "#{Dir.pwd}/./#{e}/" }
      regex_exclusion = Regexp.new("(#{absolute_exclusions.join("|")})")
      output = Nokogiri::XML(File.open(DUPLICATION_DESTINATION))
      output.xpath("//duplication").each do |duplication_node|
        if duplication_node.xpath("file").all? { |n| n["path"] =~ regex_exclusion }
          duplication_node.remove
        end
      end
      File.open(DUPLICATION_DESTINATION, 'w') { |file| file.write(output.to_s) }
    end

    private
    def xcode_version
      `xcodebuild -version`.match(/^Xcode ([0-9]+\.[0-9]+)/)[1].to_f
    end

    private 
    def puts_red(str)
      puts "\e[31m#{str}\e[0m"
    end
  end
end
# ObjectiveCi

Get up and running with useful metrics for your iOS project, integrated into a CI.

## Installation

Add this line to your application's Gemfile:

    gem 'objective-ci'

And then execute:

    $ bundle


## Usage

In your rakefile, make a new task

```ruby
require 'bundler/setup'
require 'objective-ci'

:namespace ci do
  :task build do
    # Takes care of installing pods and adding "Pods" to exclusions if Podfile is detected
    objective_ci = ObjectiveCi::CiTasks.new
    
    # Add the path of any folders/files that should not be included in the metrics
    objective_ci.exclusions << "ExternalFrameworksFolder"
    
    # Run all of the metrics on your workspace (or project)
    objective_ci.build(:workspace => "iPhoneProject.xcworkspace", :scheme => "iPhoneProjectReleaseScheme")
    
    # Or, choose which metrics you want to run on your project (or workspace)
    objective_ci.lint(:project => "iPhoneProject.project", :scheme => "iPhoneProjectReleaseScheme") # Generates lint.xml
    objective_ci.test_suite(:project => "iPhoneProject.project", :scheme => "iPhoneProjectReleaseScheme") # Generates test-reports/*.xml
    objective_ci.lines_of_code # Generates line-count.sc
    objective_ci.duplicate_code_detection # Generates duplication.xml
  end
end
```

The CI server of choice is Jenkins -- install the plugins for the metrics you plan on using.

* lint: https://wiki.jenkins-ci.org/display/JENKINS/PMD+Plugin
* lines_of_code: https://wiki.jenkins-ci.org/display/JENKINS/SLOCCount+Plugin
* duplicate_code_detection: https://wiki.jenkins-ci.org/display/JENKINS/DRY+Plugin
* test_suite: JUnit reporting is built into Jenkins.

In Jenkins, call the rake task and load in the generated files

![Jenkins Screenshot](/docs/jenkins-setup.jpg)

Triggering a build should now show the metrics in the build.

### Code signing

**Make sure to import any code signing certificates into Xcode on the continuous integration server, and to keep the provisioning profiles up to date. And, most importantly, the first time your code signing certificates are used with `objective-ci`, a dialog will appear asking you to allow `xcodebuild` to access the keychain. Click `always allow`**

## Advanced

If you peruse the binaries that `objective-ci` is using, and their documentation, you might find that you'd like to throw in some extra configurations. Go wild.

* [OCLint 0.8dev](http://docs.oclint.org/en/dev/)
* [SLOCCount](http://www.dwheeler.com/sloccount/)
* [xcodebuild](https://www.google.com/url?sa=f&rct=j&url=http://developer.apple.com/documentation/Darwin/Reference/ManPages/man1/xcodebuild.1.html&q=&esrc=s&ei=kB5mUvyQCbL62gWN8IGgAg&usg=AFQjCNG065ry1JvpdG4kiuAmQZTP-yotRQ)

These binaries currently support extra command-line arguments by passing in the option `:binaryname_options => "--your "options"`

For example, if you'd like to setup `OCLint` to only generate long-line warnings when lines exceed 120 characters in length, you could do
```ruby
  objective_ci = ObjectiveCi::CiTasks.new
  objective_ci.build(:workspace => "FooApp.xcworkspace",
                     :scheme => "FooApp",
                     :"oclint-json-compilation-database_options" => "-rc=LONG_LINE=120")
```

In addition to the blanketed `:binaryname_options` options, a few tasks support additional options.

* `duplicate_code` supports `:minimum_tokens`, which defaults to 100. This value will determine what the minimum amount of duplicated tokens is to constitute as a copy and paste violation.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

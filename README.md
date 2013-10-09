# ObjectiveCi

Get up and running with useful metrics for your iOS project, integrated into a CI.

## Installation

Add this line to your application's Gemfile:

    gem 'objective-ci', :git => 'https://github.com/SportNginLabs/objective-ci.git'
    
Retrieval from git is required, as the gem includes many binaries and jars, pushing the size up to ~70mb (too large for rubygems.org)

And then execute:

    $ bundle


## Usage

In your rakefile, make a new task

```ruby
require 'bundler/setup'
require 'objective-ci'

:namespace ci do
  :task build do
    # Takes care of installing pods if Podfile is detected
    objective_ci = ObjectiveCi::CiTasks.new
    
    # Add the path of any folders/files that should not be included in the metrics
    objective_ci.exclusions << "ExternalFrameworksFolder"
    
    # Run all of the metrics on your workspace (or project)
    objective_ci.build(:workspace => "iPhoneProject.xcworkspace", :scheme => "iPhoneProjectReleaseScheme")
    
    # Or, choose which metrics you want to run on your project (or workspace)
    objective_ci.lint(:project => "iPhoneProject.project", :scheme => "iPhoneProjectReleaseScheme") # Generates lint.xml
    objective_ci.test_suite(:project => "iPhoneProject.project", :scheme => "iPhoneProjectReleaseScheme") # Generates test-reports/
    objective_ci.lines_of_code # Generates line-count.sc
    objective_ci.duplicate_code_detection # Generates duplication.xml
  end
end
```

The CI server of choice is Jenkins -- install the plugins for the metrics you plan on using.

* lint => https://wiki.jenkins-ci.org/display/JENKINS/PMD+Plugin
* lines_of_code => https://wiki.jenkins-ci.org/display/JENKINS/SLOCCount+Plugin
* duplicate_code_detection => https://wiki.jenkins-ci.org/display/JENKINS/DRY+Plugin
* test_suite => JUNIT reporting is built into Jenkins.

In Jenkins, call the rake task and load in the generated files

![Jenkins Screenshot](/docs/jenkins-setup.jpg)

Triggering a build should now show the metrics in the build.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

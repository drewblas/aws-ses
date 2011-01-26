require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'erb'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "aws-ses"
  gem.homepage = "http://github.com/drewblas/aws-ses"
  gem.license = "MIT"
  gem.summary = %Q{Client library for Amazon's Simple Email Service's REST API}
  gem.description = gem.summary
  gem.email = "drew.blas@gmail.com"
  gem.authors = ["Drew Blas", 'Marcel Molina Jr.']
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
  gem.add_dependency 'xml-simple'
  gem.add_dependency 'builder'
  gem.add_dependency 'mime-types'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
require File.dirname(__FILE__) + '/lib/aws/ses'

namespace :doc do
  Rake::RDocTask.new do |rdoc|  
    rdoc.rdoc_dir = 'doc'  
    version = File.exist?('VERSION') ? File.read('VERSION') : ""
    rdoc.title    = "AWS::SES -- Support for Amazon SES's REST api #{version}"  
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.rdoc_files.include('README')
    rdoc.rdoc_files.include('COPYING')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
  
  task :rdoc => 'doc:readme'
  
  task :refresh => :rerdoc do
    system 'open doc/index.html'
  end

  task :readme do
    require 'support/rdoc/code_info'
    RDoc::CodeInfo.parse('lib/**/*.rb')
    
    strip_comments = lambda {|comment| comment.gsub(/^# ?/, '')}
    docs_for       = lambda do |location| 
      info = RDoc::CodeInfo.for(location)
      raise RuntimeError, "Couldn't find documentation for `#{location}'" unless info
      strip_comments[info.comment]
    end
    
    open('README', 'w') do |file|
      file.write ERB.new(IO.read('README.erb')).result(binding)
    end
  end
end

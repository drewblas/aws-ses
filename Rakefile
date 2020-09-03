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

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

# require 'rcov/rcovtask'
# Rcov::RcovTask.new do |test|
#   test.libs << 'test'
#   test.pattern = 'test/**/*_test.rb'
#   test.verbose = true
# end

task :default => :test

require 'rdoc/task'
require File.dirname(__FILE__) + '/lib/aws/ses'

namespace :doc do
  Rake::RDocTask.new do |rdoc|  
    rdoc.rdoc_dir = 'doc'  
    version = File.exist?('VERSION') ? File.read('VERSION') : ""
    rdoc.title    = "AWS::SES -- Support for Amazon SES's REST api #{version}"  
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.rdoc_files.include('README.rdoc')
    rdoc.rdoc_files.include('LICENSE')
    rdoc.rdoc_files.include('CHANGELOG')
    rdoc.rdoc_files.include('TODO')
    rdoc.rdoc_files.include('VERSION')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
  
  task :rdoc => 'doc:readme'
  
  task :refresh => :rerdoc do
    system 'open doc/index.html'
  end

  desc "Generate readme.rdoc from readme.erb"
  task :readme do
    require 'support/rdoc/code_info'
    RDoc::CodeInfo.parse('lib/**/*.rb')
    
    strip_comments = lambda {|comment| comment.gsub(/^# ?/, '')}
    docs_for       = lambda do |location| 
      info = RDoc::CodeInfo.for(location)
      raise RuntimeError, "Couldn't find documentation for `#{location}'" unless info
      strip_comments[info.comment]
    end
    
    open('README.rdoc', 'w') do |file|
      file.write ERB.new(IO.read('README.erb')).result(binding)
    end
  end
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "aws-ses"
  gem.homepage = "http://github.com/drewblas/aws-ses"
  gem.license = "MIT"
  gem.summary = "Client library for Amazon's Simple Email Service's REST API"
  gem.description = "Client library for Amazon's Simple Email Service's REST API"
  gem.email = "drew.blas@gmail.com"
  gem.authors = ["Drew Blas", "Marcel Molina Jr."]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

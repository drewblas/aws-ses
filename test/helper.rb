require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda-context'

begin
  require 'ruby-debug'
rescue LoadError
end

require 'flexmock'
require 'flexmock/test_unit'

require File.dirname(__FILE__) + '/mocks/fake_response'
require File.dirname(__FILE__) + '/fixtures'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'aws/ses'
require 'timecop'

class Test::Unit::TestCase
  require 'net/http'
  require 'net/https'
  
  include AWS::SES
  
  def mock_connection(object, data = {})
    return_values = case data
    when Hash
      FakeResponse.new(data)
    when Array
      data.map {|hash| FakeResponse.new(hash)}
    else
      abort "Response data for mock connection must be a Hash or an Array. Was #{data.inspect}."
    end
    
    connection = flexmock('Net::HTTP.new') do |mock|
      mock.should_receive(:post).and_return(*return_values).at_least.once
    end

    mock = flexmock(object)
    mock.should_receive(:connection).and_return(connection)
    mock
  end
  
  def generate_base
    Base.new(:access_key_id=>'123', :secret_access_key=>'abc')
  end
end

# Deals w/ http://github.com/thoughtbot/shoulda/issues/issue/117, see 
# http://stackoverflow.com/questions/3657972/nameerror-uninitialized-constant-testunitassertionfailederror-when-upgradin
unless defined?(Test::Unit::AssertionFailedError)
  Test::Unit::AssertionFailedError = ActiveSupport::TestCase::Assertion
end

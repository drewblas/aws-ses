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
require 'shoulda'

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

class Test::Unit::TestCase
  include AWS::SES
  
  def mock_connection_for(instance, klass, options = {})    
    data = options[:returns]
    return_values = case data
    when Hash
      FakeResponse.new(data)
    when Array
      data.map {|hash| FakeResponse.new(hash)}
    else
      abort "Response data for mock connection must be a Hash or an Array. Was #{data.inspect}."
    end
    
    connection = flexmock('Mock connection') do |mock|
      mock.should_receive(:request).and_return(*return_values).at_least.once
    end

    instance.should_receive(:connection).and_return(connection)
  end
end

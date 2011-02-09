require File.expand_path('../helper', __FILE__)

class BaseResponseTest < Test::Unit::TestCase 
  def setup
    @headers       = {'content-type' => 'text/plain', 'date' => Time.now}
    @response      = FakeResponse.new()
    @base_response = Response.new('ResponseAction', @response)
  end
  
  def test_status_predicates
    response = Proc.new {|code| Response.new('ResponseAction', FakeResponse.new(:code => code))}
    assert response[200].success?
    assert response[300].redirect?
    assert response[400].client_error?
    assert response[500].server_error?
  end
  
  def test_headers_passed_along_from_original_response
    assert_equal @response.headers, @base_response.headers
    assert_equal @response['date'], @base_response['date']
    original_headers, new_headers = {}, {}
    @response.headers.each {|k,v| original_headers[k] = v}
    @base_response.each {|k,v| new_headers[k] = v}
    assert_equal original_headers, new_headers
  end
end
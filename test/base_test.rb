require File.expand_path('../helper', __FILE__)

class BaseTest < Test::Unit::TestCase  
  def test_connection_established    
    instance = Base.new(:access_key_id => '123', :secret_access_key => 'abc')

    assert_not_nil instance.instance_variable_get("@http")
  end
  
  def test_failed_response
    @base = generate_base
    mock_connection(@base, {:code => 403, :body => %{
      <ErrorResponse>
         <Error>
            <Type>
               Sender
            </Type>
            <Code>
               ValidationError
            </Code>
            <Message>
               Value null at 'message.subject' failed to satisfy constraint: Member must not be null
            </Message>
         </Error>
         <RequestId>
            42d59b56-7407-4c4a-be0f-4c88daeea257
         </RequestId>
      </ErrorResponse>
    }})
    
    assert_raises ResponseError do
      result = @base.request('', {})
    end
    
    # assert !result.success?
    #     assert result.error?
    #     assert result.error.error?
    #     assert_equal 'ValidationError', result.error.code
  end
end

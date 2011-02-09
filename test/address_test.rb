require File.expand_path('../helper', __FILE__)

class AddressTest < Test::Unit::TestCase
  context 'verifying an address' do
    setup do
      @base = generate_base
    end

    should 'return the correct response on success' do
      mock_connection(@base, :body => %{
        <VerifyEmailAddressResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <ResponseMetadata>
            <RequestId>abc-123</RequestId>
          </ResponseMetadata>
        </VerifyEmailAddressResponse>
      })
      
      result = @base.addresses.verify('user1@example.com')
      assert result.success?
      assert_equal 'abc-123', result.request_id
    end  
  end

  context 'listing verified addressess' do 
    setup do
      @base = generate_base
    end
    
    should 'return the correct response on success' do   
      mock_connection(@base, :body => %{
        <ListVerifiedEmailAddressesResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <ListVerifiedEmailAddressesResult>
            <VerifiedEmailAddresses>
              <member>user1@example.com</member>
            </VerifiedEmailAddresses>
          </ListVerifiedEmailAddressesResult>
          <ResponseMetadata>
            <RequestId>abc-123</RequestId>
          </ResponseMetadata>
        </ListVerifiedEmailAddressesResponse>
      })
      
      result = @base.addresses.list

      assert result.success?
      assert_equal 'abc-123', result.request_id
      assert_equal %w{user1@example.com}, result.result
    end
  end


  context 'deleting a verified addressess' do 
    setup do
      @base = generate_base
    end
    
    should 'return the correct response on success' do   
      mock_connection(@base, :body => %{
        <DeleteVerifiedEmailAddressResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <ResponseMetadata>
            <RequestId>abc-123</RequestId>
          </ResponseMetadata>
        </DeleteVerifiedEmailAddressResponse>
      })
      
      result = @base.addresses.delete('user1@example.com')

      assert result.success?
      assert_equal 'abc-123', result.request_id
    end
  end
end

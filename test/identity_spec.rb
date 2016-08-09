require File.expand_path('../helper', __FILE__)

class IdentityTest < Test::Unit::TestCase
  context 'listing domain identities' do
    setup do
      @base = generate_base
    end

    should 'return the correct response on success' do
      mock_connection(@base, :body => %{
        <ListIdentitiesResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <ListIdentitiesResult>
            <Identities>
              <member>example1.com</member>
              <member>some.example.com</member>
            </Identities>
          </ListIdentitiesResult>
          <ResponseMetadata>
            <RequestId>abc1423</RequestId>
          </ResponseMetadata>
        </ListIdentitiesResponse>
      })
      result = @base.identity.list_domains.result
      assert_equal ['example1.com', 'some.example.com'], result
    end
  end

  context 'listing email identities' do
    setup do
      @base = generate_base
    end

    should 'return the correct response on success' do
      mock_connection(@base, :body => %{
        <ListIdentitiesResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <ListIdentitiesResult>
            <Identities>
              <member>jane@example.com</member>
              <member>john@example2.com</member>
              <member>thedoes@example3.com</member>
            </Identities>
          </ListIdentitiesResult>
          <ResponseMetadata>
            <RequestId>84fsaf</RequestId>
          </ResponseMetadata>
        </ListIdentitiesResponse>
      })
      result = @base.identity.list_emails.result
      assert_equal ['jane@example.com', 'john@example2.com', 'thedoes@example3.com'], result
    end
  end

end

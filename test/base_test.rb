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

  def test_ses_authorization_header_v2
    aws_access_key_id = 'fake_aws_key_id'
    aws_secret_access_key = 'fake_aws_access_key'
    time = Time.new(2021, 4, 8, 14, 07, 58, '+00:00')
    ::Timecop.freeze(time)
    base = ::AWS::SES::Base.new(
        access_key_id:     aws_access_key_id,
        secret_access_key: aws_secret_access_key,
        signature_version: 2
    )

    assert_equal 'AWS3-HTTPS AWSAccessKeyId=fake_aws_key_id, Algorithm=HmacSHA256, Signature=Yi984ReKUv7ckcrwvsBgzLlQX/1kyva74+SF+PlrwZ0=', base.get_aws_auth_header_v2
    Timecop.return
  end

  def test_ses_authorization_header_v4
    aws_access_key_id = 'fake_aws_key_id'
    aws_secret_access_key = 'fake_aws_access_key'
    time = Time.new(2020, 7, 2, 7, 17, 58, '+00:00')
    ::Timecop.freeze(time)

    base = ::AWS::SES::Base.new(
        server:            'ec2.amazonaws.com',
        access_key_id:     aws_access_key_id,
        secret_access_key: aws_secret_access_key
    )

    assert_equal 'AWS4-HMAC-SHA256 Credential=fake_aws_key_id/20200702/us-east-1/ses/aws4_request, SignedHeaders=host;x-amz-date, Signature=fb25a4a91c6f5c17637c81744998ac664d16ce70982c5ca92c0a62199ef4e7d6', base.get_aws_auth_header_v4
    Timecop.return
  end

  def test_ses_authorization_header_v4_changed_host
    aws_access_key_id = 'fake_aws_key_id'
    aws_secret_access_key = 'fake_aws_access_key'
    time = Time.new(2020, 7, 2, 7, 17, 58, '+00:00')
    ::Timecop.freeze(time)

    base = ::AWS::SES::Base.new(
        server:            'email.us-east-1.amazonaws.com',
        access_key_id:     aws_access_key_id,
        secret_access_key: aws_secret_access_key
    )

    assert_equal 'AWS4-HMAC-SHA256 Credential=fake_aws_key_id/20200702/us-east-1/ses/aws4_request, SignedHeaders=host;x-amz-date, Signature=c77a9d002342ac5b210c8f4a054712f9e00335ce9555c359ea8982acfa32db4c', base.get_aws_auth_header_v4
    Timecop.return
  end

  def test_ses_authorization_header_v4_changed_region
    aws_access_key_id = 'fake_aws_key_id'
    aws_secret_access_key = 'fake_aws_access_key'
    time = Time.new(2020, 7, 2, 7, 17, 58, '+00:00')
    ::Timecop.freeze(time)

    base = ::AWS::SES::Base.new(
        server:            'email.us-east-1.amazonaws.com',
        access_key_id:     aws_access_key_id,
        secret_access_key: aws_secret_access_key,
        region:            'eu-west-1'
    )

    assert_not_equal 'AWS4-HMAC-SHA256 Credential=fake_aws_key_id/20200702/us-east-1/ec2/aws4_request, SignedHeaders=host;x-amz-date, Signature=b872601457070ab98e7038bdcd4dc1f5eab586ececf9908525474408b0740515', base.get_aws_auth_header_v4
    Timecop.return
  end
end

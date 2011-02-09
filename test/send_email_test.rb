require File.dirname(__FILE__) + '/helper'

class SendEmailTest < Test::Unit::TestCase
  context 'when sending email' do
    setup do
      @base = generate_base
      @basic_email = { :from => 'jon@example.com', 
                        :to   => 'dave@example.com',
                        :subject => 'Subject1', 
                        :text_body => 'Body1' }
    end
    
    context 'adding to a hash' do
      should 'add array elements to the hash' do
        hash = {}
        ary  = ['x', 'y']
        @base.send(:add_array_to_hash!, hash, 'SomeKey', ary)
        expected = {'SomeKey.member.1' => 'x', 'SomeKey.member.2' => 'y'}
        assert_equal expected, hash
      end
      
      should 'add singular elements to the hash' do
        hash = {}
        ary  = 'z'
        @base.send(:add_array_to_hash!, hash, 'SomeKey', ary)
        expected = {'SomeKey.member.1' => 'z'}
        assert_equal expected, hash
      end
    end
    
    should 'send an e-mail' do
      mock_connection(@base, :body => %{
        <SendEmailResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <SendEmailResult>
            <MessageId>abc-123</MessageId>
          </SendEmailResult>
          <ResponseMetadata>
            <RequestId>xyz-123</RequestId>
          </ResponseMetadata>
        </SendEmailResponse>
      })
      
      result = @base.send_email @basic_email
      assert result.success?
      assert_equal 'abc-123', result.message_id
      assert_equal 'xyz-123', result.request_id
    end
    
    should 'send a raw e-mail with a hash object' do
      mock_connection(@base, :body => %{
        <SendRawEmailResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <SendRawEmailResult>
            <MessageId>abc-123</MessageId>
          </SendRawEmailResult>
          <ResponseMetadata>
            <RequestId>xyz-123</RequestId>
          </ResponseMetadata>
        </SendRawEmailResponse>
      })
      
      result = @base.send_raw_email(@basic_email)
      assert result.success?
      assert_equal 'abc-123', result.message_id
      assert_equal 'xyz-123', result.request_id
    end
  end
end
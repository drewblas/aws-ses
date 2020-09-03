require File.expand_path('../helper', __FILE__)

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

    should 'throw ArgumentException when attachment supplied without a body' do
      #mock_connection(@base, :body => %{
      #  <SendRawEmailResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
      #    <SendRawEmailResult>
      #      <MessageId>abc-123</MessageId>
      #    </SendRawEmailResult>
      #    <ResponseMetadata>
      #      <RequestId>xyz-123</RequestId>
      #    </ResponseMetadata>
      #  </SendRawEmailResponse>
      #})
      message = Mail.new({:from => 'jon@example.com', :to => 'dave@example.com', :subject => 'Subject1'})
      message.attachments['foo'] = { :mime_type => 'application/csv', :content => '1,2,3' }
      assert_raise ArgumentError do
        result = @base.send_raw_email message
      end
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

    should 'send a raw e-mail with a mail object' do
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

      message = Mail.new(@basic_email)
      result = @base.send_raw_email(message)
      assert result.success?
      assert_equal 'abc-123', result.message_id
      assert_equal 'xyz-123', result.request_id
      assert message.errors.empty?
      assert_equal 'abc-123@email.amazonses.com', message.message_id
    end

    context "with a standard email"  do
      setup do
        @message = Mail.new({:from => 'jon@example.com', :to => 'dave@example.com', :cc => 'sally@example.com', :subject => 'Subject1', :body => "test body"})
      end

      should "add the 2 addresses to the Destinations" do
        package = @base.send("build_raw_email", @message)
        assert_equal 'dave@example.com',  package['Destinations.member.1']
        assert_equal 'sally@example.com', package['Destinations.member.2']
      end

      should "be able to override the e-mail destinations" do
        dest_options = {:to => "another@example.com", :cc => "bob@example.com" }
        package = @base.send("build_raw_email", @message, dest_options)
        assert_equal 'another@example.com',  package['Destinations.member.1']
        assert_equal 'bob@example.com', package['Destinations.member.2']
      end
    end

    should "add the bcc address to the email destinations" do
      message = Mail.new({:from => 'jon@example.com', :bcc => "robin@example.com", :to => 'dave@example.com', :subject => 'Subject1', :body => "test body"})
      package = @base.send("build_raw_email", message)
      assert_equal 'dave@example.com',  package['Destinations.member.1']
      assert_equal 'robin@example.com', package['Destinations.member.2']
    end

    should "when only bcc address in the email" do
      message = Mail.new({:from => 'jon@example.com', :bcc => ["robin@example.com", 'dave@example.com'], :subject => 'Subject1', :body => "test body"})
      package = @base.send("build_raw_email", message)
      assert_equal 'robin@example.com', package['Destinations.member.1']
      assert_equal 'dave@example.com',  package['Destinations.member.2']
    end

    should "add the mail addresses to the email destination" do
      message = Mail.new({:from => 'jon@example.com', :to => ["robin@example.com", 'dave@example.com'], :subject => 'Subject1', :body => "test body"})

    end
  end
end

require File.expand_path('../helper', __FILE__)

class NotificationTest < Test::Unit::TestCase
  context 'setting identity notification' do
    setup do
      @base = generate_base
    end

    should 'return the correct response on success' do
      mock_connection(@base, :body => %{
        <SetIdentityNotificationTopicResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <SetIdentityNotificationTopicResult/>
          <ResponseMetadata>
            <RequestId>abc-123</RequestId>
          </ResponseMetadata>
        </SetIdentityNotificationTopicResponse>
      })

      result = @base.notifications.register('user1@example.com', 'Bounce', 'arn:aws:sns:us-east-1:123456789:my_sns_notification_topic')
      assert result.success?
      assert_equal 'abc-123', result.request_id
    end
  end

  context 'listing identity notification ses topics' do
    setup do
      @base = generate_base
    end

    should 'return the correct response on success' do
      mock_connection(@base, :body => %{
        <GetIdentityNotificationAttributesResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <GetIdentityNotificationAttributesResult>
            <NotificationAttributes>
              <entry>
                <key>johndoe@example.com</key>
                <value>
                  <BounceTopic>arn:aws:sns:us-east-1:123456789:my_bounce_notification_topic</BounceTopic>
                  <HeadersInDeliveryNotificationsEnabled>false</HeadersInDeliveryNotificationsEnabled>
                  <HeadersInBounceNotificationsEnabled>false</HeadersInBounceNotificationsEnabled>
                  <HeadersInComplaintNotificationsEnabled>false</HeadersInComplaintNotificationsEnabled>
                  <ComplaintTopic
>arn:aws:sns:us-east-1:123456789:my_notification_topic</ComplaintTopic>
                  <ForwardingEnabled>true</ForwardingEnabled>
                </value>
              </entry>
            </NotificationAttributes>
          </GetIdentityNotificationAttributesResult>
          <ResponseMetadata>
            <RequestId>abc123</RequestId>
          </ResponseMetadata>
        </GetIdentityNotificationAttributesResponse>\
      })

      response = @base.notifications.get("johndoe@example.com")
      assert_true response.bounce_notification?
      assert_true response.complaint_notification?
      assert_false response.delivery_notification?
      result = response.result
      assert_equal 'arn:aws:sns:us-east-1:123456789:my_notification_topic', result[:complaint_notification]
    end
  end

end


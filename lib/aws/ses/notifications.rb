module AWS
  module SES
    # AWS::SES::Notification provides for:
    # * Listing identity notifications
    # * Setting identiy notifications (SNS topic that you've (not require) subscribed too )
    # * Deleting identiy notification
    #
    # You can access these methods as follows:
    #
    #   ses = AWS::SES::Base.new( ... connection info ... )
    #
    #   # Get a list of the SNS topics that notifications are sent to
    #   ses.notifications.get('ole@example.com').result
    #
    #   # Set an identity notification (a SNS Topic ARN) for a one of this topics
    #   # Bounce | Complaint | Delivery
    #   ses.notifications.register('ole@example.com', 'Bounce', 'arn:aws:sns:us-east-1:12345678:my_topic_name').result
    #
    #   # Delete a notification (remove listener)
    #   ses.notifications.delete('jon@example.com')
    #
    #   # Check what notification types have been set
    #   ses.notifications.get('johndoe@example.com').bounce_notification?
    #   ses.notifications.get('johndoe@example.com').complaint_notification?
    #   ses.notifications.get('johndoe@example.com').delivery_notification?
    #
    #

    class Notifications < Base
      def initialize(ses)
        @ses = ses
      end

      def get identity
        @ses.request('GetIdentityNotificationAttributes', 'Identities.member.1' => identity)
      end

      def register identity, notification_type, arn
        @ses.request('SetIdentityNotificationTopic', 'Identity' => identity, 'NotificationType' => notification_type, 'SnsTopic' => arn)
      end

      def delete identity, notification_type
        set identiy, notification_type, nil
      end
    end

    class SetIdentityNotificationTopicResponse < AWS::SES::Response
    end

    class GetIdentityNotificationAttributesResponse < AWS::SES::Response
      def result
        if members = parsed['GetIdentityNotificationAttributesResult']['NotificationAttributes']['entry']
          if members.kind_of? Array
            raise "not implemented"
          else
            {
              bounce_notification: members['value']['BounceTopic'],
              complaint_notification: members['value']['ComplaintTopic'],
              delivery_notification: members['value']['DeliveryTopic']
            }
          end
        else
          {}
        end
      end
      memoized :result

      def bounce_notification?
        !result[:bounce_notification].nil?
      end
      def complaint_notification?
        !result[:complaint_notification].nil?
      end
      def delivery_notification?
        !result[:delivery_notification].nil?
      end
    end

    class ListIdentitiesResponse < AWS::SES::Response
      def result
        if members = parsed['ListIdentitiesResult']['Identities']
          [members['member']].flatten
        else
          []
        end
      end
      memoized :result
    end

    class Base
      def notifications
        @notifications ||= Notifications.new(self)
      end
    end
  end
end

module AWS
  module SES
    # Adds functionality for send_email and send_raw_email
    # Use the following to send an e-mail:
    #
    #   ses = AWS::SES::Base.new( ... connection info ... )
    #   ses.send_email :to        => ['jon@example.com', 'dave@example.com'],
    #                :source    => '"Steve Smith" <steve@example.com>',
    #                :subject   => 'Subject Line'
    #                :text_body => 'Internal text body'
    #
    # By default, the email "from" display address is whatever is before the @.
    # To change the display from, use the format:
    #
    #   "Steve Smith" <steve@example.com>
    #
    # You can also send Mail objects using send_raw_email:
    #
    #   m = Mail.new( :to => ..., :from => ... )
    #   ses.send_raw_email(m)
    #
    # send_raw_email will also take a hash and pass it through Mail.new automatically as well.
    #
    module SendEmail

      # Sends an email through SES
      #
      # the destination parameters can be:
      #
      # [A single e-mail string]  "jon@example.com"
      # [A array of e-mail addresses]  ['jon@example.com', 'dave@example.com']
      #
      # ---
      # = "Email address is not verified.MessageRejected (AWS::Error)"
      # If you are receiving this message and you HAVE verified the [source] please <b>check to be sure you are not in sandbox mode!</b>
      # If you have not been granted production access, you will have to <b>verify all recipients</b> as well.
      # http://docs.amazonwebservices.com/ses/2010-12-01/DeveloperGuide/index.html?InitialSetup.Customer.html
      # ---
      #
      # @option options [String] :source Source e-mail (from)
      # @option options [String] :from alias for :source
      # @option options [String] :to Destination e-mails
      # @option options [String] :cc Destination e-mails
      # @option options [String] :bcc Destination e-mails
      # @option options [String] :subject
      # @option options [String] :html_body
      # @option options [String] :text_body
      # @option options [String] :return_path The email address to which bounce notifications are to be forwarded. If the message cannot be delivered to the recipient, then an error message will be returned from the recipient's ISP; this message will then be forwarded to the email address specified by the ReturnPath parameter.
      # @option options [String] :reply_to The reploy-to email address(es) for the message.  If the recipient replies to the message, each reply-to address will receive the reply.
      # @option options
      # @return [Response] the response to sending this e-mail
      def send_email(options = {})
        package     = {}

        package['Source'] = options[:source] || options[:from]

        add_array_to_hash!(package, 'Destination.ToAddresses', options[:to]) if options[:to]
        add_array_to_hash!(package, 'Destination.CcAddresses', options[:cc]) if options[:cc]
        add_array_to_hash!(package, 'Destination.BccAddresses', options[:bcc]) if options[:bcc]

        package['Message.Subject.Data'] = options[:subject]

        package['Message.Body.Html.Data'] = options[:html_body] if options[:html_body]
        package['Message.Body.Text.Data'] = options[:text_body] || options[:body] if options[:text_body] || options[:body]

        package['ReturnPath'] = options[:return_path] if options[:return_path]

        add_array_to_hash!(package, 'ReplyToAddresses', options[:reply_to]) if options[:reply_to]

        request('SendEmail', package)
      end

      # Sends using the SendRawEmail method
      # This gives the most control and flexibility
      #
      # This uses the underlying Mail object from the mail gem
      # You can pass in a Mail object, a Hash of params that will be parsed by Mail.new, or just a string
      #
      # Note that the params are different from send_email
      # Specifically, the following fields from send_email will NOT work:
      #
      # * :source
      # * :html_body
      # * :text_body
      #
      # send_email accepts the aliases of :from & :body in order to be more compatible with the Mail gem
      #
      # This method is aliased as deliver and deliver! for compatibility (especially with Rails)
      #
      # @option mail [String] A raw string that is a properly formatted e-mail message
      # @option mail [Hash] A hash that will be parsed by Mail.new
      # @option mail [Mail] A mail object, ready to be encoded
      # @option args [String] :source The sender's email address
      # @option args [String] :destinations A list of destinations for the message.
      # @option args [String] :from alias for :source
      # @option args [String] :to alias for :destinations
      # @return [Response]
      def send_raw_email(mail, args = {})
        message = mail.is_a?(Hash) ? Mail.new(mail) : mail
        raise ArgumentError, "Attachment provided without message body" if message.has_attachments? && message.text_part.nil? && message.html_part.nil?

        raw_email = build_raw_email(message, args)
        result = request('SendRawEmail', raw_email)
        message.message_id = "<#{result.parsed['SendRawEmailResult']['MessageId']}@#{message_id_domain}>"
        result
      end

      alias :deliver! :send_raw_email
      alias :deliver  :send_raw_email

      private

      def build_raw_email(message, args = {})
        # the message.to_s includes the :to and :cc addresses
        package = { 'RawMessage.Data' => Base64::encode64(message.to_s) }
        package['Source'] = args[:from] if args[:from]
        package['Source'] = args[:source] if args[:source]
        if args[:destinations]
            add_array_to_hash!(package, 'Destinations', args[:destinations])
        else
          mail_addresses = [message.to, message.cc, message.bcc].flatten.compact
          args_addresses = [args[:to], args[:cc], args[:bcc]].flatten.compact

          mail_addresses = args_addresses unless args_addresses.empty?

          add_array_to_hash!(package, 'Destinations', mail_addresses)
        end
        package
      end

      # Adds all elements of the ary with the appropriate member elements
      def add_array_to_hash!(hash, key, ary)
        cnt = 1
        [*ary].each do |o|
          hash["#{key}.member.#{cnt}"] = o
          cnt += 1
        end
      end
    end

    class EmailResponse < AWS::SES::Response
      def result
        super["#{action}Result"]
      end

      def message_id
        result['MessageId']
      end
    end

    class SendEmailResponse < EmailResponse

    end

    class SendRawEmailResponse < EmailResponse

    end
  end
end

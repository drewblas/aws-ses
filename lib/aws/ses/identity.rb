module AWS
  module SES
    # AWS::SES::Notification provides for:

    # AWS::SES::Addresses provides for:
    # * Listing identities
    #
    # You can access these methods as follows:
    #
    #   ses = AWS::SES::Base.new( ... connection info ... )
    #
    #   # Get a list of identites (note that these include unverified domains and emails)
    #   ses.identity.list_emails.result
    #   => ['email1@example.com', email2@example.com']
    #   ses.identity.list_domains.result
    #   => ['example1.com','some.example.com']
    #

    class Identity < Base
      def initialize(ses)
        @ses = ses
      end

      # List all identities
      # Note, this may also list unverfied domains and e-mail addresses
      #
      # Usage:
      # ses.identity.list_emails.result
      # ses.identity.list_domains.result
      # =>
      # ['email1@example.com', email2@example.com']
      def list_emails
        @ses.request('ListIdentities', 'IdentityType' => 'EmailAddress')
      end
      def list_domains
        @ses.request('ListIdentities', 'IdentityType' => 'Domain')
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
      def identity
        @identity ||= Identity.new(self)
      end
    end
  end
end

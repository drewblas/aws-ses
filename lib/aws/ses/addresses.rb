module AWS
  module SES
    # AWS::SES::Addresses provides for:
    # * Listing verified e-mail addresses
    # * Adding new e-mail addresses to verify
    # * Deleting verified e-mail addresses
    #
    # You can access these methods as follows:
    #
    #   ses = AWS::SES::Base.new( ... connection info ... )
    #
    #   # Get a list of verified addresses
    #   ses.addresses.list.result
    #
    #   # Add a new e-mail address to verify
    #   ses.addresses.verify('jon@example.com')
    #
    #   # Delete an e-mail address
    #   ses.addresses.delete('jon@example.com')
    class Addresses < Base
      def initialize(ses)
        @ses = ses
      end

      # List all verified e-mail addresses
      # 
      # Usage:
      # ses.addresses.list.result
      # =>
      # ['email1@example.com', email2@example.com']
      def list
        @ses.request('ListVerifiedEmailAddresses')
      end
      
      def verify(email)
        @ses.request('VerifyEmailAddress',
          'EmailAddress' => email
        )
      end
      
      def delete(email)
        @ses.request('DeleteVerifiedEmailAddress',
          'EmailAddress' => email
        )
      end
    end
    
    class ListVerifiedEmailAddressesResponse < AWS::SES::Response
      def result
        if members = parsed['ListVerifiedEmailAddressesResult']['VerifiedEmailAddresses']
          [members['member']].flatten
        else
          []
        end
      end
      memoized :result
    end
    
    class VerifyEmailAddressResponse < AWS::SES::Response
    end
    
    class DeleteVerifiedEmailAddressResponse < AWS::SES::Response
      def result
        success?
      end
    end
    
    class Base
      def addresses
        @addresses ||= Addresses.new(self)
      end
    end
    
  end
end
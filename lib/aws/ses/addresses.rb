module AWS
  module SES
    # AWS::SES::Addresses provides for:
    # * Listing verified e-mail addresses
    # * Adding new e-mail addresses to verify
    # * Deleting verified e-mail addresses
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
        if members = parsed['VerifiedEmailAddresses']
          [members['member']].flatten
        else
          []
        end
      end
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
# A quick little extension to use this lib with with rails 2.3.X
# To use it, in your environment.rb or some_environment.rb you simply set
#
# config.after_initialize do
#  ActionMailer::Base.delivery_method = :amazon_ses
#  ActionMailer::Base.custom_amazon_ses_mailer = AWS::SES::Base.new(:secret_access_key => S3_CONFIG[:secret_access_key], :access_key_id => S3_CONFIG[:access_key_id])
# end
            
module ActionMailer
  class Base
    cattr_accessor :custom_amazon_ses_mailer
    
    def perform_delivery_amazon_ses(mail)
      raise 'AWS::SES::Base has not been intitialized.' unless @@custom_amazon_ses_mailer
      @@custom_amazon_ses_mailer.deliver!(mail)
    end

  end
end
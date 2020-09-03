= AWS::SES

AWS::SES is a Ruby library for Amazon's Simple Email Service's REST API (http://aws.amazon.com/ses).

== Getting started

To get started you need to require 'aws/ses':

  % irb -rubygems
  irb(main):001:0> require 'aws/ses'
  # => true

Before you can do anything, you must establish a connection using Base.new.  A basic connection would look something like this:

  ses = AWS::SES::Base.new(
    :access_key_id     => 'abc', 
    :secret_access_key => '123'
  )

The minimum connection options that you must specify are your access key id and your secret access key.

=== Connecting to a server from another region

The default server API endpoint is "email.us-east-1.amazonaws.com", corresponding to the US East 1 region.

To connect to a different one, just pass it as a parameter to the AWS::SES::Base initializer:

  ses = AWS::SES::Base.new(
    :access_key_id     => 'abc', 
    :secret_access_key => '123',
    :server => 'email.eu-west-1.amazonaws.com',
    :message_id_domain => 'eu-west-1.amazonses.com'
  )

== Send E-mail

Adds functionality for send_email and send_raw_email
Use the following to send an e-mail:

  ses = AWS::SES::Base.new( ... connection info ... )
  ses.send_email(
               :to        => ['jon@example.com', 'dave@example.com'],
               :source    => '"Steve Smith" <steve@example.com>',
               :subject   => 'Subject Line',
               :text_body => 'Internal text body'
  )
By default, the email "from" display address is whatever is before the @. 
To change the display from, use the format: 

  "Steve Smith" <steve@example.com>

You can also send Mail objects using send_raw_email:

  m = Mail.new( :to => ..., :from => ... )
  ses.send_raw_email(m)

send_raw_email will also take a hash and pass it through Mail.new automatically as well.



== Addresses

AWS::SES::Addresses provides for:
* Listing verified e-mail addresses
* Adding new e-mail addresses to verify
* Deleting verified e-mail addresses

You can access these methods as follows:

  ses = AWS::SES::Base.new( ... connection info ... )

  # Get a list of verified addresses
  ses.addresses.list.result

  # Add a new e-mail address to verify
  ses.addresses.verify('jon@example.com')

  # Delete an e-mail address
  ses.addresses.delete('jon@example.com')


== Info

Adds functionality for the statistics and info send quota data that Amazon SES makes available

You can access these methods as follows:

  ses = AWS::SES::Base.new( ... connection info ... )

== Get the quota information
  response = ses.quota
  # How many e-mails you've sent in the last 24 hours
  response.sent_last_24_hours
  # How many e-mails you're allowed to send in 24 hours
  response.max_24_hour_send
  # How many e-mails you can send per second
  response.max_send_rate

== Get detailed send statistics 
The result is a list of data points, representing the last two weeks of sending activity.
Each data point in the list contains statistics for a 15-minute interval.
GetSendStatisticsResponse#data_points is an array where each element is a hash with give string keys:

* +Bounces+
* +DeliveryAttempts+
* +Rejects+
* +Complaints+
* +Timestamp+

For example:

    response = ses.statistics
    response.data_points

will return:

      [{"Bounces"=>"0",
        "Timestamp"=>"2011-01-26T16:30:00Z",
        "DeliveryAttempts"=>"1",
        "Rejects"=>"0",
        "Complaints"=>"0"},
       {"Bounces"=>"0",
        "Timestamp"=>"2011-02-09T14:45:00Z",
        "DeliveryAttempts"=>"3",
        "Rejects"=>"0",
        "Complaints"=>"0"},
       {"Bounces"=>"0",
        "Timestamp"=>"2011-01-31T15:30:00Z",
        "DeliveryAttempts"=>"3",
        "Rejects"=>"0",
        "Complaints"=>"0"},
       {"Bounces"=>"0",
        "Timestamp"=>"2011-01-31T16:00:00Z",
        "DeliveryAttempts"=>"3",
        "Rejects"=>"0",
        "Complaints"=>"0"}]

== Rails

This gem is compatible with Rails >= 3.0.0 and Ruby 2.3.x

To use, first add the gem to your Gemfile:

    gem "aws-ses", "~> 0.7.0", :require => 'aws/ses'
    
== For Rails 3.x

Then, add your Amazon credentials and extend ActionMailer in `config/initializers/amazon_ses.rb`:

    ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
      :access_key_id     => 'abc',
      :secret_access_key => '123',
      :signature_version => 4

Then set the delivery method in `config/environments/*.rb` as appropriate:

    config.action_mailer.delivery_method = :ses

== For Rails 2.3.x

Then set the delivery method in `config/environments/*rb` as appropriate:

    config.after_initialize do
      ActionMailer::Base.delivery_method = :amazon_ses
      ActionMailer::Base.custom_amazon_ses_mailer = AWS::SES::Base.new(:secret_access_key => 'abc', :access_key_id => '123')
    end
    
== Issues

=== HTTP Segmentation fault

If you get this error:
    net/http.rb:677: [BUG] Segmentation fault

It means that you are not running with SSL enabled in ruby.  Re-compile ruby with ssl support or add this option to your environment:
    RUBYOPT="-r openssl"
    
=== Rejected sending

If you are receiving this message and you HAVE verified the [source] please <b>check to be sure you are not in sandbox mode!</b>
    "Email address is not verified.MessageRejected (AWS::Error)"
If you have not been granted production access, you will have to <b>verify all recipients</b> as well.

To verify email addresses and domains:
https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-addresses-and-domains.html

To request production access:
https://docs.aws.amazon.com/ses/latest/DeveloperGuide/request-production-access.html

== Source

Available at: https://github.com/drewblas/aws-ses

== Contributing to aws-ses
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2011 Drew Blas. See LICENSE for further details.

== Thanks

Special thanks to Marcel Molina Jr. for his creation of AWS::S3 which I used portions of to get things working.

=== Other Contributors:

* croaky
* nathanbertram
* sshaw
* teeparham (documentation)
* pzb

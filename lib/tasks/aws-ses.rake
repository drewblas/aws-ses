require "aws/ses"

def email
  email = ENV["EMAIL"] 
  raise "EMAIL is required" if email.nil? || email.blank?
  email
end

def print_columns(columns, data, format)
  printf format, *columns  
  [data].flatten.each { |d| printf format, *d.values_at(*columns) }
end

namespace :ses do 
  task :login do 
    key    = ENV["AWS_ACCESS_KEY_ID"]
    secret = ENV["AWS_SECRET_ACCESS_KEY"]

    if (!key || !secret) && File.exists?(ENV["AWS_CREDENTIALS_FILE"].to_s)      
      File.open(ENV["AWS_CREDENTIALS_FILE"]) do |io|
        io.each do |line|
          if line =~ /\AAWSAccessKeyId=(.+)\Z/
            key = $1 
          elsif line =~ /\AAWSSecretKey=(.+)\Z/
            secret = $1 
          end
        end
      end
    end       

    if !key || !secret
      raise "You must setup your authentication keys. Either set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables " \
            "or set the AWS_CREDENTIALS_FILE environment variable to a file containing two lines: AWSAccessKeyId=X and AWSSecretKey=Y " \
	    "where X and Y are the respected keys."
    end

    @ses = AWS::SES::Base.new(:access_key_id => key, :secret_access_key => secret)
  end

  namespace :info do 
    desc "Display send rates"
    task :quota => :login do 
      format  = "%-16s%-16s%-16s\n"      
      columns = %w{SentLast24Hours Max24HourSend MaxSendRate}      

      info = @ses.quota.result
      print_columns(columns, info, format)
    end

    desc "Display send statistics for the past 2 weeks"
    task :statistics => :login do            
      format  = "%-24s%-24s%-8s%-8s%-16s\n"      
      columns = %w{Timestamp DeliveryAttempts Rejects Bounces Complaints}
      sort_by = columns.first

      stats = @ses.statistics.result.sort { |a,b| b[sort_by] <=> a[sort_by] }
      print_columns(columns, stats, format)
    end
  end

  namespace :addresses do
    desc "List verified addresses"
    task :list => :login do 
      reply = @ses.addresses.list

      if reply.result.any?
        reply.result.sort.each { |email| puts email }
      else
        puts "No addresses have been verified"
      end
    end

    desc "Submit a verification request for the address in EMAIL"
    task :verify => :login do 
      @ses.addresses.verify(email)
      puts "Verification request sent"
    end

    desc "Delete the verified address in EMAIL"
    task :delete => :login do 
      email_to_delete = email
      reply = @ses.addresses.list

      if reply.result.include?(email_to_delete)
        @ses.addresses.delete(email_to_delete)  
        puts "Address deleted"
      else 
        $stderr.puts "Cannot delete: #{email_to_delete} is not a verified address"
      end
    end
  end
end

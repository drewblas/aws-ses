module AWS #:nodoc:
  # AWS::SES is a Ruby library for Amazon's Simple Email Service's REST API (http://aws.amazon.com/ses).
  # 
  # == Getting started
  # 
  # To get started you need to require 'aws/ses':
  # 
  #   % irb -rubygems
  #   irb(main):001:0> require 'aws/ses'
  #   # => true
  # 
  # Before you can do anything, you must establish a connection using Base.new.  A basic connection would look something like this:
  # 
  #   ses = AWS::SES::Base.new(
  #     :access_key_id     => 'abc', 
  #     :secret_access_key => '123'
  #   )
  # 
  # The minimum connection options that you must specify are your access key id and your secret access key.
  #
  # === Connecting to a server from another region
  # 
  # The default server API endpoint is "email.us-east-1.amazonaws.com", corresponding to the US East 1 region.
  # To connect to a different one, just pass it as a parameter to the AWS::SES::Base initializer:
  #
  #   ses = AWS::SES::Base.new(
  #     :access_key_id     => 'abc', 
  #     :secret_access_key => '123',
  #     :server => 'email.eu-west-1.amazonaws.com'
  #   )

  module SES
    
    API_VERSION = '2010-12-01'
    
    DEFAULT_HOST = 'email.us-east-1.amazonaws.com'
    
    USER_AGENT = 'github-aws-ses-ruby-gem'
    
    # Encodes the given string with the secret_access_key by taking the
    # hmac-sha1 sum, and then base64 encoding it.  Optionally, it will also
    # url encode the result of that to protect the string if it's going to
    # be used as a query string parameter.
    #
    # @param [String] secret_access_key the user's secret access key for signing.
    # @param [String] str the string to be hashed and encoded.
    # @param [Boolean] urlencode whether or not to url encode the result., true or false
    # @return [String] the signed and encoded string.
    def SES.encode(secret_access_key, str, urlencode=true)
      digest = OpenSSL::Digest.new('sha256')
      b64_hmac =
        Base64.encode64(
          OpenSSL::HMAC.digest(digest, secret_access_key, str)).gsub("\n","")

      if urlencode
        return CGI::escape(b64_hmac)
      else
        return b64_hmac
      end
    end
    
    # Generates the HTTP Header String that Amazon looks for
    # 
    # @param [String] key the AWS Access Key ID
    # @param [String] alg the algorithm used for the signature
    # @param [String] sig the signature itself
    def SES.authorization_header(key, alg, sig)
      "AWS3-HTTPS AWSAccessKeyId=#{key}, Algorithm=#{alg}, Signature=#{sig}"
    end
    
    # AWS::SES::Base is the abstract super class of all classes who make requests against SES
    class Base   
      include SendEmail
      include Info
      
      attr_reader :use_ssl, :server, :proxy_server, :port
      attr_accessor :settings

      # @option options [String] :access_key_id ("") The user's AWS Access Key ID
      # @option options [String] :secret_access_key ("") The user's AWS Secret Access Key
      # @option options [Boolean] :use_ssl (true) Connect using SSL?
      # @option options [String] :server ("email.us-east-1.amazonaws.com") The server API endpoint host
      # @option options [String] :proxy_server (nil) An HTTP proxy server FQDN
      # @option options [String] :user_agent ("github-aws-ses-ruby-gem") The HTTP User-Agent header value
      # @return [Object] the object.
      def initialize( options = {} )

        options = { :access_key_id => "",
                    :secret_access_key => "",
                    :use_ssl => true,
                    :server => DEFAULT_HOST,
                    :path => "/",
                    :user_agent => USER_AGENT,
                    :proxy_server => nil
                    }.merge(options)

        @server = options[:server]
        @proxy_server = options[:proxy_server]
        @use_ssl = options[:use_ssl]
        @path = options[:path]
        @user_agent = options[:user_agent]
        @settings = {}

        raise ArgumentError, "No :access_key_id provided" if options[:access_key_id].nil? || options[:access_key_id].empty?
        raise ArgumentError, "No :secret_access_key provided" if options[:secret_access_key].nil? || options[:secret_access_key].empty?
        raise ArgumentError, "No :use_ssl value provided" if options[:use_ssl].nil?
        raise ArgumentError, "Invalid :use_ssl value provided, only 'true' or 'false' allowed" unless options[:use_ssl] == true || options[:use_ssl] == false
        raise ArgumentError, "No :server provided" if options[:server].nil? || options[:server].empty?

        if options[:port]
          # user-specified port
          @port = options[:port]
        elsif @use_ssl
          # https
          @port = 443
        else
          # http
          @port = 80
        end

        @access_key_id = options[:access_key_id]
        @secret_access_key = options[:secret_access_key]

        # Use proxy server if defined
        # Based on patch by Mathias Dalheimer.  20070217
        proxy = @proxy_server ? URI.parse(@proxy_server) : OpenStruct.new
        @http = Net::HTTP::Proxy( proxy.host,
                                  proxy.port,
                                  proxy.user,
                                  proxy.password).new(options[:server], @port)

        @http.use_ssl = @use_ssl

        # Don't verify the SSL certificates.  Avoids SSL Cert warning in log on every GET.
        @http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      end
      
      def connection
        @http
      end
      
      # Make the connection to AWS passing in our request.  
      # allow us to have a one line call in each method which will do all of the work
      # in making the actual request to AWS.
      def request(action, params = {})
        # Use a copy so that we don't modify the caller's Hash, remove any keys that have nil or empty values
        params = params.reject { |key, value| value.nil? or value.empty?}
        
        timestamp = Time.now.getutc

        params.merge!( {"Action" => action,
                        "SignatureVersion" => "2",
                        "SignatureMethod" => 'HmacSHA256',
                        "AWSAccessKeyId" => @access_key_id,
                        "Version" => API_VERSION,
                        "Timestamp" => timestamp.iso8601 } )

        query = params.sort.collect do |param|
          CGI::escape(param[0]) + "=" + CGI::escape(param[1])
        end.join("&")

        req = {}

        req['X-Amzn-Authorization'] = get_aws_auth_param(timestamp.httpdate, @secret_access_key)
        req['Date'] = timestamp.httpdate
        req['User-Agent'] = @user_agent 

        response = connection.post(@path, query, req)
        
        response_class = AWS::SES.const_get( "#{action}Response" )
        result = response_class.new(action, response)
        
        if result.error?
          raise ResponseError.new(result)
        end
        
        result
      end

      # Set the Authorization header using AWS signed header authentication
      def get_aws_auth_param(timestamp, secret_access_key)
        encoded_canonical = SES.encode(secret_access_key, timestamp, false)
        SES.authorization_header(@access_key_id, 'HmacSHA256', encoded_canonical)
      end
    end # class Base
  end # Module SES
end # Module AWS

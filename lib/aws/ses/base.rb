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
  #     :server => 'email.eu-west-1.amazonaws.com',
  #     :message_id_domain => 'eu-west-1.amazonses.com'
  #   )
  #

  module SES
    
    API_VERSION = '2010-12-01'

    DEFAULT_REGION = 'us-east-1'

    SERVICE = 'ec2'

    DEFAULT_HOST = 'email.us-east-1.amazonaws.com'

    DEFAULT_MESSAGE_ID_DOMAIN = 'email.amazonses.com'
    
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

    def SES.authorization_header_v4(credential, signed_headers, signature)
      "AWS4-HMAC-SHA256 Credential=#{credential}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
    end

    # AWS::SES::Base is the abstract super class of all classes who make requests against SES
    class Base   
      include SendEmail
      include Info
      
      attr_reader :use_ssl, :server, :proxy_server, :port, :message_id_domain, :signature_version, :region
      attr_accessor :settings

      # @option options [String] :access_key_id ("") The user's AWS Access Key ID
      # @option options [String] :secret_access_key ("") The user's AWS Secret Access Key
      # @option options [Boolean] :use_ssl (true) Connect using SSL?
      # @option options [String] :server ("email.us-east-1.amazonaws.com") The server API endpoint host
      # @option options [String] :proxy_server (nil) An HTTP proxy server FQDN
      # @option options [String] :user_agent ("github-aws-ses-ruby-gem") The HTTP User-Agent header value
      # @option options [String] :region ("us-east-1") The server API endpoint host
      # @option options [String] :message_id_domain ("us-east-1.amazonses.com") Domain used to build message_id header
      # @return [Object] the object.
      def initialize( options = {} )

        options = { :access_key_id => "",
                    :secret_access_key => "",
                    :use_ssl => true,
                    :server => DEFAULT_HOST,
                    :message_id_domain => DEFAULT_MESSAGE_ID_DOMAIN,
                    :path => "/",
                    :user_agent => USER_AGENT,
                    :proxy_server => nil,
                    :region => DEFAULT_REGION
                    }.merge(options)

        @signature_version = options[:signature_version] || 2
        @server = options[:server]
        @message_id_domain = options[:message_id_domain]
        @proxy_server = options[:proxy_server]
        @use_ssl = options[:use_ssl]
        @path = options[:path]
        @user_agent = options[:user_agent]
        @region = options[:region]
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
                        "SignatureVersion" => signature_version.to_s,
                        "SignatureMethod" => 'HmacSHA256',
                        "AWSAccessKeyId" => @access_key_id,
                        "Version" => API_VERSION,
                        "Timestamp" => timestamp.iso8601 } )

        query = params.sort.collect do |param|
          CGI::escape(param[0]) + "=" + CGI::escape(param[1])
        end.join("&")

        req = {}

        req['X-Amzn-Authorization'] = get_aws_auth_param(timestamp.httpdate, @secret_access_key, action, signature_version.to_s)
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
      def get_aws_auth_param(timestamp, secret_access_key, action = '', signature_version = 2)
        encoded_canonical = SES.encode(secret_access_key, timestamp, false)
        return SES.authorization_header(@access_key_id, 'HmacSHA256', encoded_canonical) unless signature_version == 4

        SES.authorization_header_v4(sig_v4_auth_credential, sig_v4_auth_signed_headers, sig_v4_auth_signature(action))
      end

      private

      def sig_v4_auth_credential
        @access_key_id + '/' + credential_scope
      end

      def sig_v4_auth_signed_headers
        'host;x-amz-date'
      end

      def credential_scope
        datestamp + '/' + region + '/' + SERVICE + '/' + 'aws4_request'
      end

      def string_to_sign(for_action)
        "AWS4-HMAC-SHA256\n" +  amzdate + "\n" +  credential_scope + "\n" + Digest::SHA256.hexdigest(canonical_request(for_action).encode('utf-8').b)
      end


      def amzdate
        Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
      end

      def datestamp
        Time.now.utc.strftime('%Y%m%d')
      end

      def canonical_request(for_action)
        "GET" + "\n" + "/" + "\n" + canonical_querystring(for_action) + "\n" + canonical_headers + "\n" + sig_v4_auth_signed_headers + "\n" + payload_hash
      end

      def canonical_querystring(action)
        "Action=#{action}&Version=2013-10-15"
      end

      def canonical_headers
        'host:' + server + "\n" + 'x-amz-date:' + amzdate + "\n"
      end

      def payload_hash
        Digest::SHA256.hexdigest(''.encode('utf-8'))
      end

      def sig_v4_auth_signature(for_action)
        signing_key = getSignatureKey(@secret_access_key, datestamp, region, SERVICE)

        OpenSSL::HMAC.hexdigest("SHA256", signing_key, string_to_sign(for_action).encode('utf-8'))
      end

      def getSignatureKey(key, dateStamp, regionName, serviceName)
        kDate = sign(('AWS4' + key).encode('utf-8'), dateStamp)
        kRegion = sign(kDate, regionName)
        kService = sign(kRegion, serviceName)
        kSigning = sign(kService, 'aws4_request')

        kSigning
      end

      def sign(key, msg)
        OpenSSL::HMAC.digest("SHA256", key, msg.encode('utf-8'))
      end
    end # class Base
  end # Module SES
end # Module AWS

module AWS
  module SES
    class Response < String  
      attr_reader :response, :body, :parsed, :action
      
      def initialize(action, response)
        @action   = action
        @response = response
        @body     = response.body.to_s
        super(body)
      end

      def headers
        headers = {}
        response.each do |header, value|
          headers[header] = value
        end
        headers
      end
      memoized :headers

      def [](header)
        headers[header]
      end

      def each(&block)
        headers.each(&block)
      end

      def code
        response.code.to_i
      end

      {:success      => 200..299, :redirect     => 300..399,
       :client_error => 400..499, :server_error => 500..599}.each do |result, code_range|
        class_eval(<<-EVAL, __FILE__, __LINE__)
          def #{result}? 
            return false unless response
            (#{code_range}).include? code
          end
        EVAL
      end

      def error?
        !success? && response['content-type'] == 'application/xml' && parsed.root == 'error'
      end

      def error
        Error.new(parsed, self)
      end
      memoized :error

      def parsed
        parse_options = { 'forcearray' => ['item', 'member'], 'suppressempty' => nil, 'keeproot' => false }
#        parse_options = { 'suppressempty' => nil, 'keeproot' => false }

        xml = XmlSimple.xml_in(body, parse_options)
        xml["#{@action}Result"]
      end
      memoized :parsed
      
      # It's expected that each subclass of Response will override this method with what part of response is relevant
      def result
        parsed
      end

      def inspect
        "#<%s:0x%s %s %s>" % [self.class, object_id, response.code, response.message]
      end
    end  # class Response
    
    # Requests whose response code is between 300 and 599 and contain an <Error></Error> in their body
    # are wrapped in an Error::Response. This Error::Response contains an Error object which raises an exception
    # that corresponds to the error in the response body. The exception object contains the ErrorResponse, so
    # in all cases where a request happens, you can rescue ResponseError and have access to the ErrorResponse and
    # its Error object which contains information about the ResponseError.
    #
    #   begin
    #     Bucket.create(..)
    #   rescue ResponseError => exception
    #    exception.response
    #    # => <Error::Response>
    #    exception.response.error
    #    # => <Error>
    #   end
    class Error < Response
      def error? 
        true
      end
    
      def inspect
        "#<%s:0x%s %s %s: '%s'>" % [self.class.name, object_id, response.code, error.code, error.message]
      end
    end
  end #module SES
end  # module AWS


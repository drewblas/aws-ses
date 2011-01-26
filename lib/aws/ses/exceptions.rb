#--
# AWS ERROR CODES
# AWS can throw error exceptions that contain a '.' in them.
# since we can't name an exception class with that '.' I compressed
# each class name into the non-dot version which allows us to retain
# the granularity of the exception.
#++

module AWS

  # All AWS errors are superclassed by Error < RuntimeError
  class Error < RuntimeError; end

  # CLIENT : A client side argument error
  class ArgumentError < Error; end

  # Server Error Codes
  ###

  # Server : Internal Error.
  class InternalError < Error; end

  # Server : The server is overloaded and cannot handle the request.
  class Unavailable < Error; end

  # API Errors
  ############################

  # Server : Invalid AWS Account
  class InvalidClientTokenId < Error; end

  # Server : The provided signature does not match.
  class SignatureDoesNotMatch < Error; end
  
  # SES Errors
  ############################
  
  

end


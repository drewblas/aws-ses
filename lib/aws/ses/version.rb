module AWS
  module SES
    module VERSION #:nodoc:
      MAJOR    = '0'
      MINOR    = '4'
      TINY     = '2' 
      BETA     = Time.now.to_i.to_s
    end
    
    Version = [VERSION::MAJOR, VERSION::MINOR, VERSION::TINY, VERSION::BETA].compact * '.'
  end
end

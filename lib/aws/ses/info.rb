module AWS
  module SES
    # Adds functionality for the statistics and info functionality
    #
    # You can call 'quota' or 'statistics'
    module Info
      # Returns quota information provided by SES
      # 
      # The return format inside the response result will look like:
      #   {"SentLast24Hours"=>"0.0", "MaxSendRate"=>"1.0", "Max24HourSend"=>"200.0"}
      def quota
        request('GetSendQuota')
      end
      
      def statistics
        request('GetSendStatistics')
      end
    end
    
    class GetSendQuotaResponse < AWS::SES::Response
    end
    
    class GetSendStatisticsResponse < AWS::SES::Response
    end
  end
end
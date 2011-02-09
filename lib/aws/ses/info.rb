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
      def result
        parsed['GetSendQuotaResult']
      end
      
      def sent_last_24_hours
        result['SentLast24Hours']
      end
      
      def max_24_hour_send
        result['Max24HourSend']
      end
      
      def max_send_rate
        result['MaxSendRate']
      end
    end
    
    class GetSendStatisticsResponse < AWS::SES::Response
      def result
        if members = parsed['GetSendStatisticsResult']['SendDataPoints']
          [members['member']].flatten
        else
          []
        end
      end
      
      memoized :result
      
      def data_points
        result
      end
    end
  end
end
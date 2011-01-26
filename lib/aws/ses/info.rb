module AWS
  module SES
    # Adds functionality for the statistics and info functionality
    module Info
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
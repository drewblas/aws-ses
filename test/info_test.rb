require File.expand_path('../helper', __FILE__)

class InfoTest < Test::Unit::TestCase
  context 'getting send quota' do
    setup do
      @base = generate_base
    end

    should 'return the correct response on success' do
      mock_connection(@base, :body => %{
        <GetSendQuotaResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <GetSendQuotaResult>
            <SentLast24Hours>0.0</SentLast24Hours>
            <Max24HourSend>1000.0</Max24HourSend>
            <MaxSendRate>1.0</MaxSendRate>
          </GetSendQuotaResult>
          <ResponseMetadata>
            <RequestId>abc-123</RequestId>
          </ResponseMetadata>
        </GetSendQuotaResponse>
      })
      
      result = @base.quota
      assert result.success?
      assert_equal 'abc-123', result.request_id
      assert_equal '0.0', result.sent_last_24_hours
      assert_equal '1000.0', result.max_24_hour_send
      assert_equal '1.0', result.max_send_rate
    end  
  end

  context 'getting send statistics' do 
    setup do
      @base = generate_base
    end
    
    should 'return the correct response on success' do   
      mock_connection(@base, :body => %{
        <GetSendStatisticsResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <GetSendStatisticsResult>
            <SendDataPoints>
              <member>
                <DeliveryAttempts>3</DeliveryAttempts>
                <Timestamp>2011-01-31T15:31:00Z</Timestamp>
                <Rejects>2</Rejects>
                <Bounces>4</Bounces>
                <Complaints>1</Complaints>
              </member>
              <member>
                <DeliveryAttempts>3</DeliveryAttempts>
                <Timestamp>2011-01-31T16:01:00Z</Timestamp>
                <Rejects>0</Rejects>
                <Bounces>0</Bounces>
                <Complaints>0</Complaints>
              </member>
              <member>
                <DeliveryAttempts>1</DeliveryAttempts>
                <Timestamp>2011-01-26T16:31:00Z</Timestamp>
                <Rejects>0</Rejects>
                <Bounces>0</Bounces>
                <Complaints>0</Complaints>
              </member>
            </SendDataPoints>
          </GetSendStatisticsResult>
          <ResponseMetadata>
            <RequestId>abc-123</RequestId>
          </ResponseMetadata>
        </GetSendStatisticsResponse>
      })
      
      result = @base.statistics

      assert result.success?
      assert_equal 'abc-123', result.request_id
      
      assert_equal 3, result.data_points.size
      
      d = result.data_points.first
      
      assert_equal '2', d['Rejects']
      assert_equal '3', d['DeliveryAttempts']
      assert_equal '4', d['Bounces']
      assert_equal '1', d['Complaints']
    end
  end


  context 'deleting a verified addressess' do 
    setup do
      @base = generate_base
    end
    
    should 'return the correct response on success' do   
      mock_connection(@base, :body => %{
        <DeleteVerifiedEmailAddressResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
          <ResponseMetadata>
            <RequestId>abc-123</RequestId>
          </ResponseMetadata>
        </DeleteVerifiedEmailAddressResponse>
      })
      
      result = @base.addresses.delete('user1@example.com')

      assert result.success?
      assert_equal 'abc-123', result.request_id
    end
  end
end

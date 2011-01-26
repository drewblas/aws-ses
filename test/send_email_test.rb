require File.dirname(__FILE__) + '/helper'

class SendEmailTest < Test::Unit::TestCase
  context "when sending email" do
    setup do
      @base = generate_base
    end
    
    context "adding to a hash" do
      should 'add array elements to the hash' do
        hash = {}
        ary  = ['x', 'y']
        @base.send(:add_array_to_hash!, hash, 'SomeKey', ary)
        expected = {'SomeKey.member.1' => 'x', 'SomeKey.member.2' => 'y'}
        assert_equal expected, hash
      end
      
      should 'add singular elements to the hash' do
        hash = {}
        ary  = 'z'
        @base.send(:add_array_to_hash!, hash, 'SomeKey', ary)
        expected = {'SomeKey.member.1' => 'z'}
        assert_equal expected, hash
      end
    end
    
    # should "send an e-mail" do
    #   mock_connection(@base)
    #   
    #   result = @base.send_email :from => 'jon@example.com', 
    #                             :to   => 'dave@example.com',
    #                             :subject => 'Subject1', 
    #                             :text_body => 'Body1'
    #   assert result.success?
    # end
  end
end
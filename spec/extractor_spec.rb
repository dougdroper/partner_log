# encoding: UTF-8

require 'spec_helper'

describe "Extraction" do
  it "generates an interaction for each logfile line that indicates order selection" do
    file = StringIO.new("Skip this line\nAdmin::OrdersController#show as JSON yada yada\n Parameters: ")
    Output.should_receive(:puts).once
    subject = Extractor.new(file)
    subject.run
  end

  it "generates an interaction for each logfile line that indicates action taken" do
    file = StringIO.new("Skip this line\nAdmin::OrdersController#update as JSON yada yada\n")
    Output.should_receive(:puts).once
    subject = Extractor.new(file)
    subject.run
  end

  it "generates an interaction for each logfile line that indicates auth token issued" do
    file = StringIO.new("Skip this line\nAdmin::SessionsController#create as HTML yada yada\n")
    Output.should_receive(:puts).once
    subject = Extractor.new(file)
    subject.run
  end

  it "An interaction record states the start timestamp, end timestamp, duration, order_id, partner_login_email, and action." do
    file = StringIO.new <<-EOF
2013-08-04 07:05:39 (17661) INFO: Processing by Admin::SessionsController#create as HTML
2013-08-04 07:05:39 (17661) INFO:   Parameters: {"utf8"=>"✓", "authenticity_token"=>"IQV9YlBIlHjq6lQUtuGpx8ySD3hP65/cX41pixI0/lA=", "email"=>"joe@joe.com", "password"=>"[FILTERED]", "commit"=>"Log in"}
2013-08-04 18:11:39 (21699) INFO: Processing by Admin::OrdersController#show as JSON
2013-08-04 18:11:39 (21699) INFO:   Parameters: {"_dc"=>"1375636302737", "id"=>"5150189", "authenticity_token"=>"IQV9YlBIlHjq6lQUtuGpx8ySD3hP65/cX41pixI0/lA="}
2013-08-04 18:11:44 (7592) INFO: Processing by Admin::OrdersController#update as JSON
2013-08-04 18:11:44 (7592) INFO:   Parameters: {"order"=>"{\"confirmation_note\":\"\",\"partial\":false,\"decline_reason_code\":\"\",\"other_decline_reason\":\"\",\"estimated_dispatch_at\":\"\",\"estimated_dispatch_date\":\"in 5 days\",\"custom_estimated_dispatch_date\":\"\",\"estimated_delivery_date\":\"\",\"dispatch_note_viewed\":false,\"delivery_recipient_first_name\":\"Louise\",\"delivery_recipient_last_name\":\"Jenkins-Lang\",\"state_event\":\"accept\",\"resolve_enquiry\":false,\"notification_disabled\":false,\"id\":5150189,\"lock_version\":3}", "authenticity_token"=>"IQV9YlBIlHjq6lQUtuGpx8ySD3hP65/cX41pixI0/lA=", "id"=>"5150189"}
EOF
    Output.should_receive(:puts).with("2013-08-04 18:11:39, 2013-08-04 18:11:44, 5, 5150189, joe@joe.com, accept")
    Extractor.new(file).run
  end


  context "processing a show event" do
    before do
      line = StringIO.new <<-EOF
        2013-08-04 07:05:39 (17661) INFO: Processing by Admin::SessionsController#create as HTML
        2013-08-04 07:05:39 (17661) INFO:   Parameters: {"utf8"=>"✓", "authenticity_token"=>"TEST_TOKEN", "email"=>"joe@joe.com", "password"=>"[FILTERED]", "commit"=>"Log in"} 
      EOF
    end

    it "extracts token"
    it "sets an ActionIntervals"
    it "does not generate an output line"  
    it "finds an associated email address"
  end
  
  context "processing an update event" do
    it "finds an associated email address"
    it "updates ActionIntervals "
    it "generates an output line"  
  end
end

describe ParameterLine do
  let(:line) { '2013-08-04 07:05:39 (17661) INFO:   Parameters: {"utf8"=>"✓", "authenticity_token"=>"TEST_TOKEN", "email"=>"joe@joe.com", "password"=>"[FILTERED]", "commit"=>"Log in"}' }
  
  subject { ParameterLine.new(line) }
  it "extract the params from the string" do
    subject.params.should == {"utf8"=>"✓", "authenticity_token"=>"TEST_TOKEN", "email"=>"joe@joe.com", "password"=>"[FILTERED]", "commit"=>"Log in"}
  end
end

describe EmailLookup do
  it "tracks emails by token" do
    params = {"utf8"=>"✓", "authenticity_token"=>"IQV9YlBIlHjq6lQUtuGpx8ySD3hP65/cX41pixI0/lA=", "email"=>"joe@joe.com", "password"=>"[FILTERED]", "commit"=>"Log in"}
    subject.insert(params)
    subject.find("IQV9YlBIlHjq6lQUtuGpx8ySD3hP65/cX41pixI0/lA=").should == "joe@joe.com"
  end
end


describe ActionInterval do
  context "set an interval" do
    let(:token)  { "IQV9YlBIlHjq6lQUtuGpx8ySD3hP65/cX41pixI0/lA=" }
    let(:order_id) { '5150189' }
    let(:start_time) { Time.parse('2013-08-04 18:11:39') }
    let(:end_time) { Time.parse('2013-08-04 18:11:44') }
    let(:start_action) { 'show' }
    let(:end_action) { 'accept' }

    it "returns nil if none exists" do
      ActionInterval.set(start_time, token, order_id, start_action).should_not be
    end

    describe "ending an interval" do
      subject do 
        ActionInterval.set(start_time, token, order_id, start_action)
        ActionInterval.set(end_time, token, order_id, end_action)
      end

      its(:start_time) { should == start_time }
      its(:end_time) { should == end_time }
      its(:start_action) { should == start_action }
      its(:end_action) { should == end_action }
      its(:duration) { should == 5.0 }
    end
    

    describe "ending an interval again" do
      let (:end_time_2) { Time.parse('2013-08-04 18:11:50') }
      let (:end_action_2) { 'yeehaa' }
    
      subject do 
        ActionInterval.set(start_time, token, order_id, start_action)
        ActionInterval.set(end_time, token, order_id, end_action)
        ActionInterval.set(end_time_2, token, order_id, end_action_2)
      end

      its(:start_time) { should == end_time }
      its(:end_time) { should == end_time_2 }
      its(:start_action) { should == end_action }
      its(:end_action) { should == end_action_2 }
    end
  end

end



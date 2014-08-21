require 'spec_helper'

describe PadmaStatsApi do
  describe "#count_students" do
    let(:monthly_stat){create(:school_monthly_stat,
                              name: 'students',
                              service: 'crm',
                              school: school)}
    context "for an account with relative values" do
      let(:school){create(:school,
                          count_students_relative_to_value: 10,
                          count_students_relative_to_date: Date.civil(2014,1,1)
                         )}
      it "calls CRM with relative_to" do
        Typhoeus::Request.should_receive(:get).with(an_instance_of(String),
                                      params: hash_including(:relative_to),
                                      sslversion: :sslv3).and_return mocked_response
        monthly_stat.get_remote_value
      end
    end
    context "for an account without relative values" do
      let(:school){create(:school)}
      it "calls CRM with relative_to" do
        Typhoeus::Request.should_receive(:get).with(an_instance_of(String),
                                      params: hash_not_including(:relative_to),
                                      sslversion: :sslv3).and_return mocked_response
        monthly_stat.get_remote_value
      end
    end
  end

  def mocked_response
    double(success?: false)
  end
end

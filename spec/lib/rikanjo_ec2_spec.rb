require "spec_helper"
require "aws/rikanjo/mode/ec2"

include RikanjoSpecHelper

describe 'AWS::Rikanjo::Mode::Ec2' do

  describe 'previous type' do
    it "is previous instance type" do
      %w{ m1.medium c1.medium m2.xlarge cc2.8xlarge cr1.8xlarge hi1.4xlarge cg1.4xlarge }.each do |t|
          a = Aws::RiKanjoo::Mode::Ec2.new(
              region        = 'ap-northeast-1',
              instance_type = t,
              ri_util       = 'light',
          )
          expect(a.previous_generation_type).to eq true
      end
    end

    it "is current instance type" do
      %w{ t1.micro m1.small m3.medium c3.medium r3.xlarge i2.xlarge }.each do |t|
          a = Aws::RiKanjoo::Mode::Ec2.new(
              region        = 'ap-northeast-1',
              instance_type = t,
              ri_util       = 'light',
          )
          expect(a.previous_generation_type).to eq false
      end
    end
  end

  describe 'url' do
    it "build previous price url" do
      a = Aws::RiKanjoo::Mode::Ec2.new(
          region        = 'ap-northeast-1',
          instance_type = 'm1.medium',
          ri_util       = 'light',
      )
      expect(a.price_url).to eq "http://a0.awsstatic.com/pricing/1/ec2/previous-generation"
    end

    it "build current price url" do
      a = Aws::RiKanjoo::Mode::Ec2.new(
          region        = 'ap-northeast-1',
          instance_type = 'm3.medium',
          ri_util       = 'light',
      )
      expect(a.price_url).to eq "http://a0.awsstatic.com/pricing/1/ec2"
    end

    it "build previous ri price file" do
      a = Aws::RiKanjoo::Mode::Ec2.new(
          region        = 'ap-northeast-1',
          instance_type = 'm1.medium',
          ri_util       = 'light',
      )
      expect(a.ri_price_file).to eq "light_linux.min.js"
    end

    it "build current ri price file" do
      a = Aws::RiKanjoo::Mode::Ec2.new(
          region        = 'ap-northeast-1',
          instance_type = 'm3.medium',
          ri_util       = 'heavy',
      )
      expect(a.ri_price_file).to eq "linux-ri-heavy.min.js"
    end

  end

  describe 'contents validation' do

    before :all do
      # rikanjo (current)
      a1 = Aws::RiKanjoo::Mode::Ec2.new(
          region        = 'ap-northeast-1',
          instance_type = 'm3.medium',
          ri_util       = 'medium',
      )
      # rikanjo (previous)
      a2 = Aws::RiKanjoo::Mode::Ec2.new(
          region        = 'ap-northeast-1',
          instance_type = 'm1.medium',
          ri_util       = 'medium',
      )
      @c_om_current_price = get_sleep("#{a1.price_url}/#{a1.om_price_file}")
      @c_ri_current_medium_price = get_sleep("#{a1.price_url}/#{a1.ri_price_file}")
      @c_om_previous_price = get_sleep("#{a2.price_url}/#{a2.om_price_file}")
      @c_ri_previous_medium_price = get_sleep("#{a2.price_url}/#{a2.ri_price_file}")
    end

    it "is able to get the price" do
      regions.each do |region|
        a = Aws::RiKanjoo::Mode::Ec2.new(
            region        = region,
            instance_type = 'm3.large',
            ri_util       = 'medium',
        )
        # om
        om_info = a.om_price_from_contents(@c_om_current_price)
        expect(om_info[:hr_price]).not_to be_nil
        # ri
        ri_info = a.ri_price_from_contents(@c_ri_current_medium_price)
        expect(ri_info["medium"][:upfront]).not_to be_nil
        expect(ri_info["medium"][:hr_price]).not_to be_nil
      end
    end

    it "an exception is raised when there are no instance-type" do
      regions.each do |region|
        a = Aws::RiKanjoo::Mode::Ec2.new(
            region        = region,
            instance_type = 'm3.large.not.exists',
            ri_util       = 'medium',
        )
        # raise om
        expect do
          om_info = a.om_price_from_contents(@c_om_current_price)
        end.to raise_error(SystemExit)
        # raise ri
        expect do
          ri_info = a.ri_price_from_contents(@c_ri_current_medium_price)
        end.to raise_error(SystemExit)
      end
    end

  end

end

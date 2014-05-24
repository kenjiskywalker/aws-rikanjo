require "spec_helper"
require "aws/rikanjo/rds"

include RikanjoSpecHelper

describe 'AWS::Rikanjo::Rds' do

  describe 'url' do

    it "build current price url" do
      a = Aws::RiKanjoo::Rds.new(
          region        = 'ap-northeast-1',
          instance_type = 'm3.large',
          ri_util       = 'light',
          multiaz       = false,
      )
      expect(a.price_url).to eq "https://a0.awsstatic.com/pricing/1/rds/mysql"
    end

    it "build current om price file" do
      a = Aws::RiKanjoo::Rds.new(
          region        = 'ap-northeast-1',
          instance_type = 'm2.xlarge',
          ri_util       = 'medium',
          multiaz       = false,
      )
      expect(a.om_price_file).to eq "pricing-standard-deployments.min.js"
    end

    it "build current om price file(multiaz)" do
      a = Aws::RiKanjoo::Rds.new(
          region        = 'ap-northeast-1',
          instance_type = 'm2.xlarge',
          ri_util       = 'medium',
          multiaz       = true,
      )
      expect(a.om_price_file).to eq "pricing-multiAZ-deployments.min.js"
    end

    it "build current ri price file" do
      a = Aws::RiKanjoo::Rds.new(
          region        = 'ap-northeast-1',
          instance_type = 'm2.xlarge',
          ri_util       = 'medium',
          multiaz       = true,
      )
      expect(a.ri_price_file).to eq "pricing-medium-utilization-reserved-instances.min.js"
    end

  end


  describe 'contents validation' do

    before :all do
      # rikanjo (single-az)
      a1 = Aws::RiKanjoo::Rds.new(
          region        = 'ap-northeast-1',
          instance_type = 'm3.medium',
          ri_util       = 'medium',
          multiaz       = false,
      )
      # rikanjo (multi-az)
      a2 = Aws::RiKanjoo::Rds.new(
          region        = 'ap-northeast-1',
          instance_type = 'm3.medium',
          ri_util       = 'medium',
          multiaz       = true,
      )
      @c_om_singleaz_price = get_sleep("#{a1.price_url}/#{a1.om_price_file}")
      @c_ri_medium_price   = get_sleep("#{a1.price_url}/#{a1.ri_price_file}")
      @c_om_multiaz_price  = get_sleep("#{a2.price_url}/#{a2.om_price_file}")
    end

    it "is able to get the price(singleaz)" do
      regions.each do |region|
        a = Aws::RiKanjoo::Rds.new(
            region        = region,
            instance_type = 'm3.large',
            ri_util       = 'medium',
            multiaz       = false,
        )
        # om
        om_info = a.om_price_from_contents(@c_om_singleaz_price)
        expect(om_info[:hr_price]).not_to be_nil

        # ri
        ri_info = a.ri_price_from_contents(@c_ri_medium_price)
        expect(ri_info["medium"][:upfront]).not_to be_nil
        expect(ri_info["medium"][:hr_price]).not_to be_nil
      end
    end

    it "is able to get the price(multiaz)" do
      regions.each do |region|
        a = Aws::RiKanjoo::Rds.new(
            region        = region,
            instance_type = 'm3.large',
            ri_util       = 'medium',
            multiaz       = true,
        )
        # om
        om_info = a.om_price_from_contents(@c_om_multiaz_price)
        expect(om_info[:hr_price]).not_to be_nil

        # ri
        ri_info = a.ri_price_from_contents(@c_ri_medium_price)
        expect(ri_info["medium"][:upfront]).not_to be_nil
        expect(ri_info["medium"][:hr_price]).not_to be_nil
      end
    end

    it "an exception is raised when there are no instance-type" do
      regions.each do |region|
        a = Aws::RiKanjoo::Rds.new(
            region        = region,
            instance_type = 'm3.large.not.exists',
            ri_util       = 'medium',
            multiaz       = false,
        )
        # raise om
        expect do
          om_info = a.om_price_from_contents(@c_om_singleaz_price)
        end.to raise_error(SystemExit)
        # raise ri
        expect do
          ri_info = a.ri_price_from_contents(@c_ri_medium_price)
        end.to raise_error(SystemExit)
      end
    end
  end

end

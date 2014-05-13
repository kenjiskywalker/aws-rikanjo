require "spec_helper"
require "aws/rikanjo/mode/rds"

include RikanjoSpecHelper

describe 'AWS::Rikanjo::Mode::Rds' do

  describe 'url' do

    it "build current price url" do
      a = Aws::RiKanjoo::Mode::Rds.new(
          region        = 'ap-northeast-1',
          instance_type = 'm3.large',
          ri_util       = 'light',
          multiaz       = false,
      )
      expect(a.price_url).to eq "https://a0.awsstatic.com/pricing/1/rds/mysql"
    end

    it "build current om price file" do
      a = Aws::RiKanjoo::Mode::Rds.new(
          region        = 'ap-northeast-1',
          instance_type = 'm2.xlarge',
          ri_util       = 'medium',
          multiaz       = false,
      )
      expect(a.om_price_file).to eq "pricing-standard-deployments.min.js"
    end

    it "build current om price file(multiaz)" do
      a = Aws::RiKanjoo::Mode::Rds.new(
          region        = 'ap-northeast-1',
          instance_type = 'm2.xlarge',
          ri_util       = 'medium',
          multiaz       = true,
      )
      expect(a.om_price_file).to eq "pricing-multiAZ-deployments.min.js"
    end

    it "build current ri price file" do
      a = Aws::RiKanjoo::Mode::Rds.new(
          region        = 'ap-northeast-1',
          instance_type = 'm2.xlarge',
          ri_util       = 'medium',
          multiaz       = true,
      )
      expect(a.ri_price_file).to eq "pricing-medium-utilization-reserved-instances.min.js"
    end

  end


end

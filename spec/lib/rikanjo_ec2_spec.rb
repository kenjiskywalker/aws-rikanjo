require "spec_helper"
require "aws/rikanjo/mode/ec2"

describe 'AWS::Rikanjo::Mode::Ec2' do

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

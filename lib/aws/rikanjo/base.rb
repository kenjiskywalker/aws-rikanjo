require 'aws/rikanjo/ec2'
require 'aws/rikanjo/rds'
require 'aws/rikanjo/calc'

module Aws
  module RiKanjoo
    class Base < Calc
      attr_reader :region, :instance_type, :ri_util, :multiaz

      def initialize(mode = 'ec2', region, instance_type, ri_util, multiaz)
        if mode == 'ec2'
          @mode = Aws::RiKanjoo::Ec2.new(region, instance_type, ri_util)
        elsif mode == 'rds'
          @mode = Aws::RiKanjoo::Rds.new(region, instance_type, ri_util, multiaz)
        end
        @region        = region
        @instance_type = instance_type
        @ri_util       = ri_util
        @om_info       = {}
        @ri_info       = {}
      end
    end
  end
end

# m = Aws::RiKanjoo.new(region = "ap-northeast-1", instance_type = "m3.large", ri_util = "medium")
# m.total_cost_year
#
#  "region" : ap-northeast-1
#  "instance_type" : m3.large
#  "ri_util" : medium
#  "discont percent (percent)" : 35.09
#  "ondemand hour price (doller)" : 0.203
#  "reserved hour price (doller)" : 0.086
#  "ondemand year price (doller)" : 1778.28
#  "reserved year price (doller)" : 1154.36
#  "reserved upfront (doller)" : 401
#  "sweet spot day (day)" : 142
#  "sweet spot date (date)" : 2014-09-19
#  "sweet spot price (doller)" : 696.15

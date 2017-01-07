require 'aws/rikanjo/resource'

module Aws
  module RiKanjoo
    class Ec2 < Resource
      attr_reader :region, :instance_type, :ri_util

      def initialize(region:, instance_type:, ri_util:, os:'linux')
        @region             = region
        @instance_type      = instance_type
        @ri_util            = ri_util
        @os                 = os ||= 'linux'
        @resource           = 'ec2'
        @term               = 'yrTerm1Standard'
        @current_price_url  = 'https://a0.awsstatic.com/pricing/1/ec2/ri-v2'
      end

      def price_url
        return @current_price_url
      end

      def ri_price_file
        case @os
        when 'linux'   then 'linux-unix-shared.min.js'
        when 'windows' then 'windows-shared.min.js'
        end
      end
    end
  end
end

require 'aws/rikanjo/resource'

module Aws
  module RiKanjoo
    class Rds < Resource
      attr_reader :region, :instance_type, :ri_util

      def initialize(region:, instance_type:, ri_util:, rdbms:, multiaz: false)
        @region            = region
        @instance_type     = "db.#{instance_type}"
        @ri_util           = ri_util
        @rdbms             = rdbms ||= 'mysql'
        @multiaz           = multiaz
        @resource          = 'rds'
        @term              = 'yrTerm1'
        @current_price_url = "https://a0.awsstatic.com/pricing/1/rds/reserved-instances"
      end

      def price_url
        return @current_price_url
      end

      def ri_price_file
        return (@multiaz) ? "#{@rdbms}-multiAZ.min.js" : "#{@rdbms}-standard.min.js"
      end

    end
  end
end

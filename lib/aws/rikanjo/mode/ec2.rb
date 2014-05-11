require 'yajl'

module Aws
  class RiKanjoo
    class Mode
      class Ec2
        attr_reader :region, :instance_type, :ri_util

        def initialize(region, instance_type, ri_util)
          @region             = region
          @instance_type      = instance_type
          @ri_util            = ri_util
          @os                 = 'linux'
          @current_price_url  = 'http://a0.awsstatic.com/pricing/1/ec2'
          @previous_price_url = 'http://a0.awsstatic.com/pricing/1/ec2/previous-generation'
        end

        def om_price_from_contents contents
          region = self.convert_region(@region)

          # parse
          json = self.parse_contents(contents)

          # select 'region' and 'instance_type'
          json["config"]["regions"].each do |r|
            # r = {"region"=>"us-east", "instanceTypes"=>[{"type"=>"generalCurrentGen", ...
            next unless r["region"] == region
            r["instanceTypes"].each do |type|
              # type = {"type"=>"generalCurrentGen", "sizes"=>[{"size"=>"m3.medium", "vCPU"=>"1" ...
              type["sizes"].each do |i|
                next unless i["size"] == @instance_type

                return {:hr_price => i["valueColumns"][0]["prices"]["USD"]}
              end
            end
          end
        end

        def ri_price_from_contents contents
          region = @region

          # parse
          json = self.parse_contents(contents)

          ri_info = {}

          json["config"]["regions"].each do |r|
            next unless r["region"] == region
            r["instanceTypes"].each do |type|
              type["sizes"].each do |i|
                next unless i["size"] == @instance_type

                i["valueColumns"].each do |y|
                  case y["name"]
                  when "yrTerm1"
                    ri_info[@ri_util] = {:upfront => y["prices"]["USD"]}
                  when "yrTerm1Hourly"
                    ri_info[@ri_util].store(:hr_price, y["prices"]["USD"])
                  end
                end
              end
            end
          end

          return ri_info
        end

        def price_url
          return (self.previous_generation_type) ? @previous_price_url : @current_price_url
        end

        def om_price_file
          return "#{@os}-od.min.js"
        end

        def ri_price_file
          return (self.previous_generation_type) ? "#{@ri_util}_#{@os}.min.js" : "#{@os}-ri-#{@ri_util}.min.js"
        end

        def previous_generation_type
          case @instance_type
          when /^(c1|m2|cc2\.8xlarge|cr1\.8xlarge|hi1\.4xlarge|cg1\.4xlarge)/ then true
          when /^m1/ then (@instance_type == "m1.small") ? false : true
          else false
          end
        end

        def parse_contents data
          data = data.gsub("/*\n * This file is intended for use only on aws.amazon.com. We do not guarantee its availability or accuracy.\n *\n * Copyright 2014 Amazon.com, Inc. or its affiliates. All rights reserved.\n */\ncallback({",'{').gsub("\);", '').gsub(/([a-zA-Z]+):/, '"\1":')
          return Yajl::Parser.parse(data)
        end

        def convert_region region
          # not same om region
          case region
          when "us-east-1"      then "us-east"
          when "us-west-1"      then "us-west"
          when "eu-west-1"      then "eu-ireland"
          when "ap-southeast-1" then "apac-sin"
          when "ap-northeast-1" then "apac-tokyo"
          when "ap-southeast-2" then "apac-syd"
          when "sa-east-1"      then "sa-east-1"
          end
        end

      end
    end
  end
end

#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'yajl'
require 'date'

module Aws
  class RiKanjoo
    attr_reader :region, :instance_type, :ri_util

    def initialize(region, instance_type, ri_util)
      @region        = region
      @instance_type = instance_type
      @ri_util       = ri_util
      @om_info       = Hash.new
      @ri_info       = Hash.new
      @current_price_url  = 'http://a0.awsstatic.com/pricing/1/ec2'
      @previous_price_url = 'http://a0.awsstatic.com/pricing/1/ec2/previous-generation'
    end

    def om_get_hr_price
      region             = @region
      instance_type      = @instance_type
      json               = nil
      ondemandjson_data  = nil

      # not same ri region
      case region
      when "us-west-1"
        region = "us-west"
      when "eu-west-1"
        region = "eu-ireland"
      when "ap-southeast-1"
        region = "apac-sin"
      when "ap-northeast-1"
        region = "apac-tokyo"
      when "ap-southeast-2"
        region = "apac-syd"
      when "sa-east-1"
        region = "sa-east-1"
      end

       # TODO: merge om and ri
      uri = URI.parse("#{price_url}/linux-od.min.js")
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.get(uri.request_uri)
        json = response.body
      end

      # parse
      json = json.gsub("/*\n * This file is intended for use only on aws.amazon.com. We do not guarantee its availability or accuracy.\n *\n * Copyright 2014 Amazon.com, Inc. or its affiliates. All rights reserved.\n */\ncallback({vers:0.01,",'{').gsub("\);", '').gsub(/([a-zA-Z]+):/, '"\1":')
      ondemand_json_data = Yajl::Parser.parse(json)

      # select 'region' and 'instance_type'
      ondemand_json_data["config"]["regions"].each do |r|
        # r = {"region"=>"us-east", "instanceTypes"=>[{"type"=>"generalCurrentGen", ...
        next unless r["region"] == region
        r["instanceTypes"].each do |type|
          # type = {"type"=>"generalCurrentGen", "sizes"=>[{"size"=>"m3.medium", "vCPU"=>"1" ...
          type["sizes"].each do |i|
            next unless i["size"] == instance_type
            @om_info = {:hr_price => i["valueColumns"][0]["prices"]["USD"]}
          end
        end
      end

      # :hr_price => price
      return @om_info
    end

    def ri_get_hr_price_and_upfront
      region = @region

      # not same om region
      case region
      when "us-west"
        region = "us-west-1"
      when "eu-ireland"
        region = "eu-west-1"
      when "apac-sin"
        region = "ap-southeast-1"
      when "apac-tokyo"
        region = "ap-northeast-1"
      when "apac-syd"
        region = "ap-southeast-2"
      when "sa-east-1"
        region = "sa-east-1"
      end

      get_ri_price(region)
    end

    def get_ri_price(region)
      ri_util = @ri_util

      region            = region
      instance_type     = @instance_type
      json              = nil
      reservedjson_data = nil

      uri = URI.parse("#{price_url}/#{ri_price_file}")
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.get(uri.request_uri)
        json = response.body
      end

      json = json.gsub("/*\n * This file is intended for use only on aws.amazon.com. We do not guarantee its availability or accuracy.\n *\n * Copyright 2014 Amazon.com, Inc. or its affiliates. All rights reserved.\n */\ncallback({",'{').gsub("\);", '').gsub(/([a-zA-Z]+):/, '"\1":')
      reservedjson_data = Yajl::Parser.parse(json)

      reservedjson_data["config"]["regions"].each do |r|
        next unless r["region"] == region
        r["instanceTypes"].each do |type|
          type["sizes"].each do |i|
            next unless i["size"] == instance_type

            i["valueColumns"].each do |y|
              case y["name"]
              when "yrTerm1"
                @ri_info[ri_util] = {:upfront => y["prices"]["USD"]}
              when "yrTerm1Hourly"
                @ri_info[ri_util].store(:hr_price, y["prices"]["USD"])
              end
            end
          end
        end
      end
      # exp. {"light"=>{:upfront=>"270", :hr_price=>"0.206"}}
      return @ri_info
    end

    def calc_year_cost

      om_hr_price = @om_info[:hr_price].to_f
      ri_hr_price = @ri_info[@ri_util][:hr_price].to_f
      upfront    = @ri_info[@ri_util][:upfront].to_f

      om_day_paid = (om_hr_price * 24).to_f
      ri_day_paid = (ri_hr_price * 24).to_f

      sum_om_price = om_day_paid
      sum_ri_price = ri_day_paid + upfront
      365.times.each do |d|
        d = d + 1
        sum_om_price = sum_om_price + om_day_paid
        sum_ri_price = sum_ri_price + ri_day_paid

        if sum_ri_price < sum_om_price
          @ri_info[@ri_util].store(:sweet_spot_price, sum_ri_price.round(2))
          @ri_info[@ri_util].store(:sweet_spot_start_day, d)
          break 
        end
      end
      total_om_price = (om_day_paid * 365).round(2)
      @om_info.store(:yr_price, total_om_price)
      total_ri_price = ((ri_day_paid * 365) + upfront).round(2)
      @ri_info[@ri_util].store(:yr_price, total_ri_price)

      # exp. @om_info = {:hr_price=>"0.350", :yr_price=>3066.0}
      # exp. @ri_info = {"ri_util"=>{:upfront=>"NNN", :hr_price=>"NNN",
      #                  :sweet_spot_price=>NNN, :sweet_spot_start_day=>78, :yr_price=>2074.56}}
      return @om_info, @ri_info
    end

    def total_cost_year
       om_get_hr_price
       ri_get_hr_price_and_upfront
       calc_year_cost 

       discount_per = (100 - ((@ri_info[@ri_util][:yr_price] / @om_info[:yr_price]) * 100)).round(2)

       # If the Reserved Instance does not become cheaper than the On-demand Instance.
       if @ri_info[@ri_util][:sweet_spot_start_day].nil?
         puts "\"Price of the Reserved Instance is higher than the price of On-Demand Instances.\""
         puts "\"region\" : #{@region}"
         puts "\"instance_type\" : #{@instance_type}"
         puts "\"ri_util\" : #{@ri_util}"
         puts "\"discont percent (percent)\" : #{discount_per}"
         puts "\"ondemand hour price (doller)\" : #{@om_info[:hr_price]}"
         puts "\"reserved hour price (doller)\" : #{@ri_info[@ri_util][:hr_price]}"
         puts "\"ondemand year price (doller)\" : #{@om_info[:yr_price]}"
         puts "\"reserved year price (doller)\" : #{@ri_info[@ri_util][:yr_price]}"
         puts "\"reserved upfront (doller)\" : #{@ri_info[@ri_util][:upfront]}"

         exit 1
       end

       sweet_spot_date = Date.today + @ri_info[@ri_util][:sweet_spot_start_day]

       puts "\"region\" : #{@region}"
       puts "\"instance_type\" : #{@instance_type}"
       puts "\"ri_util\" : #{@ri_util}"
       puts "\"discont percent (percent)\" : #{discount_per}"
       puts "\"ondemand hour price (doller)\" : #{@om_info[:hr_price]}"
       puts "\"reserved hour price (doller)\" : #{@ri_info[@ri_util][:hr_price]}"
       puts "\"ondemand year price (doller)\" : #{@om_info[:yr_price]}"
       puts "\"reserved year price (doller)\" : #{@ri_info[@ri_util][:yr_price]}"
       puts "\"reserved upfront (doller)\" : #{@ri_info[@ri_util][:upfront]}"
       puts "\"sweet spot day (day)\" : #{@ri_info[@ri_util][:sweet_spot_start_day]}"
       puts "\"sweet spot date (date)\" : #{sweet_spot_date}"
       puts "\"sweet spot price (doller)\" : #{@ri_info[@ri_util][:sweet_spot_price]}"
    end

    def price_url
      return (previous_generation_type) ? @previous_price_url : @current_price_url
    end

    def ri_price_file
      return (previous_generation_type) ? "#{@ri_util}_linux.min.js" : "linux-ri-#{@ri_util}.min.js"
    end

    def previous_generation_type
      case @instance_type
      when /^(c1|m2|cc2\.8xlarge|cr1\.8xlarge|hi1\.4xlarge|cg1\.4xlarge)/ then true
      when /^m1/ then (@instance_type == "m1.small") ? false : true
      else false
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

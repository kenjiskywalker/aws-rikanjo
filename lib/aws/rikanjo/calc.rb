require 'net/http'
require 'uri'
require 'yajl'
require 'date'
require 'json'

module Aws
  module RiKanjoo
    class Calc
      def ri_get_hr_price_and_upfront
        uri = URI.parse("#{@mode.price_url}/#{@mode.ri_price_file}")
        contents = Net::HTTP.get(uri)

        # parse ri info
        @om_info, @ri_info = @mode.ri_price_from_contents(contents)
      end

      def calc_year_cost
        om_hr_price = @om_info[:hr_price].to_f
        ri_mon_price = @ri_info[@ri_util][:mon_price].to_f
        ri_hr_price = @ri_info[@ri_util][:effective_hr_price].to_f
        upfront    = @ri_info[@ri_util][:upfront].to_f

        om_mon_paid = (om_hr_price * 24 * 30.5).to_f
        ri_mon_paid = ri_mon_price

        sum_om_price = om_mon_paid
        sum_ri_price = ri_mon_paid + upfront
        12.times.each do |d|
          d += 1
          sum_om_price += om_mon_paid
          sum_ri_price += ri_mon_paid

          if sum_ri_price < sum_om_price
            @ri_info[@ri_util].store(:sweet_spot_price, sum_ri_price.round(2))
            @ri_info[@ri_util].store(:sweet_spot_start_month, d)
            break
          end
        end
        total_om_price = (om_hr_price * 24 * 365).round(2)
        @om_info.store(:yr_price, total_om_price)
        total_ri_price = (upfront + (ri_mon_price * 12)).round(2)
        @ri_info[@ri_util].store(:yr_price, total_ri_price)

        # exp. @om_info = {:hr_price=>"0.350", :yr_price=>3066.0}
        # exp. @ri_info = {"ri_util"=>{:upfront=>"NNN", :hr_price=>"NNN",
        #                  :sweet_spot_price=>NNN, :sweet_spot_start_month=>78, :yr_price=>2074.56}}
        return @om_info, @ri_info
      end

      def total_cost_year
        ri_get_hr_price_and_upfront
        calc_year_cost

        discount_per = (100 - ((@ri_info[@ri_util][:yr_price] / @om_info[:yr_price]) * 100)).round(2)

        # If the Reserved Instance does not become cheaper than the On-demand Instance.
        if @ri_info[@ri_util][:sweet_spot_start_month].nil?
          message = {
            "Price of the Reserved Instance is higher than the price of On-Demand Instances." => nil,
            "region"                       => "#{@region}",
            "instance_type"                => "#{@instance_type}",
            "ri_util"                      => "#{@ri_util}",
            "discont percent (percent)"    => "#{discount_per}",
            "ondemand hour price (doller)" => "#{@om_info[:hr_price]}",
            "reserved effective hour price (doller)" => "#{@ri_info[@ri_util][:effective_hr_price]}",
            "reserved monthly price (doller)" => "#{@ri_info[@ri_util][:mon_price]}",
            "ondemand year price (doller)" => "#{@om_info[:yr_price]}",
            "reserved year price (doller)" => "#{@ri_info[@ri_util][:yr_price]}",
            "reserved upfront (doller)"    => "#{@ri_info[@ri_util][:upfront]}",
            "savings over omdemand"        => "#{@ri_info[@ri_util][:savings_over_od]}",
          }
          puts message
          exit 1
        end

        sweet_spot_date = Date.new(Time.now.year, Time.now.month, 1) >> @ri_info[@ri_util][:sweet_spot_start_month]
        message = {
          "region"                       => "#{@region}",
          "instance_type"                => "#{@instance_type}",
          "ri_util"                      => "#{@ri_util}",
          "discont percent (percent)"    => "#{discount_per}",
          "ondemand hour price (doller)" => "#{@om_info[:hr_price]}",
          "reserved effective hour price (doller)" => "#{@ri_info[@ri_util][:effective_hr_price]}",
          "reserved monthly price (doller)" => "#{@ri_info[@ri_util][:mon_price]}",
          "ondemand year price (doller)" => "#{@om_info[:yr_price]}",
          "reserved year price (doller)" => "#{@ri_info[@ri_util][:yr_price]}",
          "reserved upfront (doller)"    => "#{@ri_info[@ri_util][:upfront]}",
          "sweet spot month (month)"     => "#{@ri_info[@ri_util][:sweet_spot_start_month]}",
          "sweet spot date (date)"       => "#{sweet_spot_date}",
          "sweet spot price (doller)"    => "#{@ri_info[@ri_util][:sweet_spot_price]}",
          "savings over omdemand"        => "#{@ri_info[@ri_util][:savings_over_od]}",
        }
        return message
      end
    end
  end
end

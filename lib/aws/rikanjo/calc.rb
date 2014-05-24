require 'net/http'
require 'uri'
require 'yajl'
require 'date'

module Aws
  module RiKanjoo
    class Calc
      def om_get_hr_price
         # TODO: merge om and ri
        uri = URI.parse("#{@mode_class.price_url}/#{@mode_class.om_price_file}")
        contents = Net::HTTP.get(uri)

        # parse om info
        @om_info = @mode_class.om_price_from_contents(contents)
      end

      def ri_get_hr_price_and_upfront
        uri = URI.parse("#{@mode_class.price_url}/#{@mode_class.ri_price_file}")
        contents = Net::HTTP.get(uri)

        # parse ri info
        @ri_info = @mode_class.ri_price_from_contents(contents)
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
          d += 1
          sum_om_price += om_day_paid
          sum_ri_price += ri_day_paid

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
    end
  end
end

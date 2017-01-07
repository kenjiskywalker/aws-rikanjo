require 'aws/rikanjo/base'

module Aws
  module RiKanjoo
    class Resource
      def ri_price_from_contents(contents)
        region = @region

        # parse
        json = parse_contents(contents)

        om_info, ri_info = nil, nil

        json['config']['regions'].each do |r|
          next unless r['region'] == region

          r['instanceTypes'].each do |i|
            next unless i['type'] == @instance_type

            i['terms'].each do |t|
              next unless t['term'] == @term

              ri_info = ri_info ||= {}
              om_info = t["onDemandHourly"][0].select{|k,v| k=='prices' }.map{|k,v| [:hr_price, v['USD']] }.to_h

              t['purchaseOptions'].each do |p|
                c_ri_util = convert_purchase_options(p['purchaseOption'])
                ri_info[c_ri_util] = { savings_over_od: p['savingsOverOD'] }

                p['valueColumns'].each do |y|
                  case y['name']
                  when 'upfront'
                    ri_info[c_ri_util].store(:upfront, y['prices']['USD'])
                  when 'monthlyStar'
                    ri_info[c_ri_util].store(:mon_price, y['prices']['USD'])
                  when 'effectiveHourly'
                    ri_info[c_ri_util].store(:effective_hr_price, y['prices']['USD'])
                  end
                end
              end
            end
          end
        end

        abort("[#{@resource}][#{region}][#{@instance_type}] Not found ri-price?") unless ri_info

        return om_info, ri_info
      end

      def parse_contents(data)
        data = data.gsub(%r|/\*\R \* This file is intended for use only on aws\.amazon\.com\. We do not guarantee its availability or accuracy\.\R \*\R \* Copyright \d{4} Amazon\.com, Inc\. or its affiliates\. All rights reserved\.\R \*/\Rcallback\({|,'{').gsub("\);", '').gsub(/([a-zA-Z]+):/, '"\1":')
        return Yajl::Parser.parse(data)
      end

      def convert_purchase_options(util)
        case util
        when 'noUpfront' then 'light'
        when 'partialUpfront' then 'medium'
        when 'allUpfront' then 'heavy'
        end
      end
    end
  end
end

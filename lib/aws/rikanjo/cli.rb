require 'optparse'
require 'aws/rikanjo/base'

module Aws
  module RiKanjoo
    class CLI
      options = {}
      optparse = OptionParser.new do |opts|
        opts.banner = 'Usage: rikanjo ec2/rds [options]'

        # subcommand
        mode = ARGV.shift
        if mode == 'ec2'
        elsif mode == 'rds'
          opts.on('--multiaz', 'enable multi-az') do |value|
            options[:multiaz] = value
          end
        else
          $stderr.puts "no such subcommand: #{mode}"
          puts opts
          exit 1
        end
        options[:mode] = mode

        region_values = %w(us-east-1 us-west-1 us-west-2 eu-west-1 ap-southeast-1 ap-northeast-1 ap-southeast-2 sa-east-1 )
        opts.on('-r', '--region=VALUE', region_values, "specify aws-region (#{region_values.join('/')})") do |value|
          options[:region] = value
        end

        opts.on('-t', '--instance_type=VALUE', 'specify ec2-instance-type') do |value|
          options[:instance_type] = value
        end

        ri_util_values = %w(light medium heavy)
        opts.on('-u', '--ri_util=VALUE', ri_util_values, "specify ri-util (#{ri_util_values.join('/')})") do |value|
          options[:ri_util] = value
        end

        opts.on('-h', '--help') do
          puts opts
          exit
        end
      end

      # validation
      begin
        optparse.parse!
        require_args = [:region, :instance_type, :ri_util]
        error_args = require_args.select { |param| options[param].nil? }
        unless error_args.empty?
          puts "require arguments: #{error_args.join(', ')}"
          puts
          puts optparse
          exit
        end
      rescue
        puts $!.to_s
        puts
        puts optparse
        exit
      end

      # rikanjo
      a = Aws::RiKanjoo::Base.new(
          mode = options[:mode],
          region = options[:region],
          instance_type = options[:instance_type],
          ri_util = options[:ri_util],
          multiaz = options[:multiaz],
      )
      a.total_cost_year
    end
  end
end

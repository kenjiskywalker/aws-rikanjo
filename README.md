# Aws::Rikanjo

RI Cost Calc Tool.

## Installation

Add this line to your application's Gemfile:

    gem 'aws-rikanjo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aws-rikanjo

## Usage

example

```
require "./aws-rikanjo/lib/aws/rikanjo"

a = Aws::RiKanjoo.new(region = "ap-northeast-1", instance_type = "m1.large", ri_util = "light")
a.total_cost_year

# "region" : ap-northeast-1
# "instance_type" : m1.large
# "ri_util" : light
# "discont percent (percent)" : 32.34
# "ondemand hour price (doller)" : 0.350
# "reserved hour price (doller)" : 0.206
# "ondemand year price (doller)" : 3066.0
# "reserved year price (doller)" : 2074.56
# "reserved upfront (doller)" : 270
# "sweet spot day (day)" : 78
# "sweet spot date (date)" : 2014-07-16
# "sweet spot price (doller)" : 660.58
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

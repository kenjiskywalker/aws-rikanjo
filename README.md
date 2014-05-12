# Aws::Rikanjo

RI Cost Calc Tool( Only new price ).

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
require "aws/rikanjo"

a = Aws::RiKanjoo.new(region = "ap-northeast-1", instance_type = "m3.large", ri_util = "medium")
a.total_cost_year
# "region" : ap-northeast-1
# "instance_type" : m3.large
# "ri_util" : medium
# "discont percent (percent)" : 35.09
# "ondemand hour price (doller)" : 0.203
# "reserved hour price (doller)" : 0.086
# "ondemand year price (doller)" : 1778.28
# "reserved year price (doller)" : 1154.36
# "reserved upfront (doller)" : 401
# "sweet spot day (day)" : 142
# "sweet spot date (date)" : 2014-09-19
# "sweet spot price (doller)" : 696.15
```

## CLI Usage

### EC2

help text:

```
$ rikanjo ec2 --help
Usage: rikanjo ec2/rds [options]
    -r, --region=VALUE               specify aws-region (us-east-1/us-west-1/us-west-2/eu-west-1/ap-southeast-1/ap-northeast-1/ap-southeast-2/sa-east-1)
    -t, --instance_type=VALUE        specify ec2-instance-type
    -u, --ri_util=VALUE              specify ri-util (light/medium/heavy)
    -h, --help
```

example:

```
$ rikanjo ec2 -r ap-northeast-1 -t c3.large -u medium
```

### RDS

help text:

```
$ rikanjo rds --help
Usage: rikanjo ec2/rds [options]
        --multiaz                    enable multi-az
    -r, --region=VALUE               specify aws-region (us-east-1/us-west-1/us-west-2/eu-west-1/ap-southeast-1/ap-northeast-1/ap-southeast-2/sa-east-1)
    -t, --instance_type=VALUE        specify ec2-instance-type
    -u, --ri_util=VALUE              specify ri-util (light/medium/heavy)
    -h, --help
```

example:

```
$ rikanjo rds -r ap-northeast-1 -t m2.xlarge -u heavy --multiaz
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

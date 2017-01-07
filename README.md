# Aws::Rikanjo [![Build Status](https://travis-ci.org/kenjiskywalker/aws-rikanjo.svg?branch=master)](https://travis-ci.org/kenjiskywalker/aws-rikanjo)
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

a = Aws::RiKanjoo::Base.new('ec2', 'ap-northeast-1', 'm3.xlarge', 'medium')
a.total_cost_year
{
  "sweet spot price (doller)": "269.08",
  "sweet spot date (date)": "2015-02-17",
  "sweet spot day (day)": "254",
  "reserved upfront (doller)": "61",
  "region": "us-east-1",
  "instance_type": "m1.small",
  "ri_util": "light",
  "discont percent (percent)": "6.9",
  "ondemand hour price (doller)": "0.044",
  "reserved hour price (doller)": "0.034",
  "ondemand year price (doller)": "385.44",
  "reserved year price (doller)": "358.84"
}
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
    -j, --output_json                specify output_json flg
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
        --rdbms=VALUE                specify rdbms(mysql / aurora)
        --multiaz                    enable multi-az
    -r, --region=VALUE               specify aws-region (us-east-1/us-west-1/us-west-2/eu-west-1/ap-southeast-1/ap-northeast-1/ap-southeast-2/sa-east-1)
    -t, --instance_type=VALUE        specify ec2-instance-type
    -u, --ri_util=VALUE              specify ri-util (light/medium/heavy)
    -j, --output_json                specify output_json flg
    -h, --help
```

example:

```
$ rikanjo rds -r ap-northeast-1 -t r3.xlarge -u heavy --multiaz
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

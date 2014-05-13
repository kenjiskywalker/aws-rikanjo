require 'rspec'

Dir["./support/**/*.rb"].each do |f|
      require f
end

RSpec.configure do |config|
end

module RikanjoSpecHelper
  def regions
    return %w{
      eu-west-1
      sa-east-1
      us-east-1
      ap-northeast-1
      us-west-2
      us-west-1
      ap-southeast-1
      ap-southeast-2
    }
  end

  def get_sleep url
    contents = Net::HTTP.get(URI.parse(url))
    sleep 1
    return contents
  end

end

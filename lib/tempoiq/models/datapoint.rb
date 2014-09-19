require 'time'

module TempoIQ
  class DataPoint
    attr_reader :ts, :value

    def initialize(ts, value)
      @ts = ts
      @value = value
    end

    def to_hash
      {
        't' => ts.iso8601(3),
        'v' => value
      }
    end

    def self.from_hash(hash)
      new(Time.parse(hash['t']), m['v'])
    end
  end
end

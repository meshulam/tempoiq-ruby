require 'time'

module TempoIQ
  # The core type of TempoIQ. Holds a timestamp and value.
  class DataPoint
    # The timestamp of the datapoint [Time]
    attr_reader :ts

    # The value of the datapoint [Fixnum / Float]
    attr_reader :value

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

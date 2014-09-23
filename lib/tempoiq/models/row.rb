module TempoIQ
  # Represents all the data found at a single timestamp.
  #
  # The hierarchy looks like:
  # - timestamp
  #   - device_key
  #     - sensor_key => value
  class Row
    # Timestamp of the row
    attr_reader :ts

    # Data at the timestamp [Hash]
    #
    # Looks like: {"device1" => {"sensor1" => 1.23, "sensor2" => 2.34}}
    attr_reader :values
    
    def initialize(ts, values)
      @ts = ts
      @values = values
    end
    
    def self.from_hash(hash)
      new(hash['t'], hash['data'])
    end

    # Convenience method to select a single (device, sensor)
    # value from within the row.
    def value(device_key, key)
      @values[device_key][key]
    end
  end
end

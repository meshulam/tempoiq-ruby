module TempoIQ
  class Row
    attr_reader :ts, :data
    
    def initialize(ts, data)
      @ts = ts
      @data = data
    end
    
    def self.from_hash(hash)
      new(hash['t'], hash['data'])
    end

    def value(device_key, key)
      @data[device_key][key]
    end
  end
end

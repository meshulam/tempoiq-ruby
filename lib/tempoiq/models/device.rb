module TempoIQ
  class Device
    attr_reader :key, :name, :attributes, :sensors

    def initialize(key, name, attributes, sensors = [])
      @key = key
      @name = name
      @attributes = attributes
      @sensors = sensors
    end

    def to_hash
      {
        'key' => key,
        'name' => name,
        'attributes' => attributes,
        'sensor' => sensors
      }
    end
  end
end

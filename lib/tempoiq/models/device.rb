require 'tempoiq/models/sensor'

module TempoIQ
  class Device
    attr_reader :key
    attr_accessor :name, :attributes, :sensors

    def initialize(key, name = "", attributes = {}, *sensors)
      @key = key
      @name = name
      @attributes = attributes
      @sensors = sensors
    end

    def self.from_hash(hash)
      new(hash['key'], hash['name'], hash['attributes'],
          *hash['sensors'].map { |s| Sensor.new(s['key'], s['name'], s['attributes']) })
    end

    def to_hash
      {
        'key' => key,
        'name' => name,
        'attributes' => attributes,
        'sensors' => sensors.map(&:to_hash)
      }
    end
  end
end

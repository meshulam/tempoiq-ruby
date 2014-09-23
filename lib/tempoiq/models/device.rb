require 'tempoiq/models/sensor'

module TempoIQ
  # The top level container for a group of sensors.
  class Device
    # The primary key of the device [String]
    attr_reader :key

    # Human readable name of the device [String] EG - "My Device"
    attr_accessor :name

    # Indexable attributes. Useful for grouping related Devices.
    # EG - {'location' => '445-w-Erie', 'model' => 'TX75', 'region' => 'Southwest'}
    attr_accessor :attributes

    # Sensors attached to the device [Array] (Sensor)
    attr_accessor :sensors

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

module TempoIQ
  # The container for a stream of time series DataPoints.
  class Sensor
    # The sensor primary key [String]
    attr_reader :key

    # Human readable name of the sensor [String] EG - "Thermometer 1"
    attr_accessor :name

    # Indexable attributes. Useful for grouping related sensors.
    # EG - {'unit' => 'F', 'model' => 'FHZ343'}
    attr_accessor :attributes

    def initialize(key, name = "", attributes = {})
      @key = key
      @name = name
      @attributes = attributes
    end

    def to_hash
      {
        'key' => key,
        'name' => name,
        'attributes' => attributes
      }
    end
  end
end

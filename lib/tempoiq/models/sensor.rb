module TempoIQ
  class Sensor
    attr_reader :key
    attr_accessor :name, :attributes

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

module TempoIQ
  class BulkWrite
    def initialize
      @writes = Hash.new do |sensors, device_key|
        sensors[device_key] = Hash.new do |points, sensor_key|
          points[sensor_key] = []
        end
      end
    end

    def <<(device_key, sensor_key, datapoint)
      add(device_key, sensor_key, datapoint)
    end

    def add(device_key, sensor_key, datapoint)
      @writes[device_key][sensor_key] << datapoint.to_hash
    end

    def to_hash
      @writes
    end
  end
end


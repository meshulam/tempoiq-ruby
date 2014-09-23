module TempoIQ
  # Used to write DataPoints into your TempoIQ backend.
  class BulkWrite
    def initialize
      @writes = Hash.new do |sensors, device_key|
        sensors[device_key] = Hash.new do |points, sensor_key|
          points[sensor_key] = []
        end
      end
    end

    # Alias for #add
    def <<(device_key, sensor_key, datapoint)
      add(device_key, sensor_key, datapoint)
    end

    # Add a DataPoint to the request
    #
    # * +device_key+ [String] - The device key to write to
    # * +sensor_key+ [String] - The sensor key within the device to write to
    # * +datapoint+ [DataPoint] - The datapoint to write
    def add(device_key, sensor_key, datapoint)
      @writes[device_key][sensor_key] << datapoint.to_hash
    end

    def to_hash
      @writes
    end
  end
end


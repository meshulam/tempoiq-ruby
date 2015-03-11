require 'rubygems'
require 'json'
require 'uri'

require 'tempoiq/models/bulk_write'
require 'tempoiq/models/cursor'
require 'tempoiq/models/datapoint'
require 'tempoiq/models/delete_summary'
require 'tempoiq/models/device'
require 'tempoiq/models/find'
require 'tempoiq/models/multi_status'
require 'tempoiq/models/pipeline'
require 'tempoiq/models/query'
require 'tempoiq/models/read'
require 'tempoiq/models/row'
require 'tempoiq/models/search'
require 'tempoiq/models/selection'
require 'tempoiq/models/single'
require 'tempoiq/remoter/live_remoter'

module TempoIQ
  class ClientError < StandardError
  end

  MEDIA_PREFIX = "application/prs.tempoiq"

  # TempoIQ::Client is the main interface to your TempoIQ backend.
  # 
  # The client is broken down into two main sections:
  #
  # [Device Provisioning]
  #   - #create_device
  #   - #update_device
  #   - #delete_device
  #   - #delete_devices
  #   - #get_device
  #   - #list_devices
  #
  # [DataPoint Reading / Writing]
  #   - #write_bulk
  #   - #write_device
  #   - #read
  #
  # == Key Concepts:
  #
  # === Selection - A way to describe a grouping of related objects. Used primarily in Device / Sensor queries.
  class Client
    # Your TempoIQ backend key (String)
    attr_reader :key

    # TempoIQ backend secret (String)
    attr_reader :secret

    # TempoIQ backend host, found on your TempoIQ backend dashboard (String)
    attr_reader :host

    # Whether to use SSL or not. Defaults to true (Boolean, default: true)
    attr_reader :secure

    # Makes the backend calls (Remoter, default: LiveRemoter)
    attr_reader :remoter

    # Create a TempoIQ API Client
    # 
    # * +key+ [String] - Your TempoIQ backend key
    # * +secret+ [String] - TempoIQ backend secret
    # * +host+ [String] - TempoIQ backend host, found on your TempoIQ backend dashboard
    # * +port+ (optional) [Integer] - TempoIQ backend port
    # * +opts+ (optional) [Hash] - Optional client parameters
    #
    # ==== Options
    # * +:secure+ [Boolean] - Whether to use SSL or not. Defaults to true
    # * +:remoter+ [Remoter] - Which backend to issue calls with. Defaults to LiveRemoter
    def initialize(key, secret, host, port = 443, opts = {})
      @key = key
      @secret = secret
      @host = host
      @port = port
      @secure = opts.has_key?(:secure) ? opts[:secure] : true
      @remoter = opts[:remoter] || LiveRemoter.new(key, secret, host, port, secure)
    end

    # Create a Device in your TempoIQ backend
    #
    # * +key+ [String] - Device key
    # * +name+ (optional) [String] - Human readable device name
    # * +attributes+ (optional) [Hash] - A hash of device attributes. Keys / values are strings.
    # * +sensors+ (optional) [Array] - An array of Sensor objects to attach to the device
    #
    # On success:
    # - Returns the Device created
    # On failure:
    # - Raises HttpException
    #
    # ==== Example
    #
    #    # Create a device keyed 'heatpump4789' with 2 attached sensors
    #    device = client.create_device('heatpump4789', 'Basement Heat Pump',
    #                                  'building' => '445 W Erie', 'model' => '75ZX',
    #                                  TempoIQ::Sensor.new('temp-1'), TempoIQ::Sensor.new('pressure-1'))
    def create_device(key, name = "", attributes = {}, *sensors)
      device = Device.new(key, name, attributes, *sensors)
      remoter.post("/v2/devices", JSON.dump(device.to_hash)).on_success do |result|
        json = JSON.parse(result.body)
        Device.from_hash(json)
      end
    end

    # Fetch a device by key
    #
    # * +device_key+ [String] - The device key to fetch by
    #
    # On success:
    # - Returns the Device found, nil when not found
    # On failure:
    # - Raises HttpException
    #
    # ==== Example
    #    # Lookup the device keyed 'heatpump4789'
    #    device = client.get_device('heatpump4789')
    #    device.sensors.each { |sensor| puts sensor.key }
    def get_device(device_key)
      result = remoter.get("/v2/devices/#{URI.escape(device_key)}")
      case result.code
      when HttpResult::OK
        json = JSON.parse(result.body)
        Device.from_hash(json)
      when HttpResult::NOT_FOUND
        nil
      else
        raise HttpException.new(result)
      end
    end

    # Search for a set of devices based on Selection criteria
    #
    # * +selection+ - Device search criteria. See Selection.
    #
    # On success:
    # - Return Cursor of Devices.
    # On failure:
    # - Raises HttpException after first Cursor iteration (lazy iteration)
    #
    # ==== Example
    #    # Select devices in building in the Evanston region
    #    client.list_devices(:devices => {:and => [{:attribute_key => 'building'}, {:attributes => {'region' => 'Evanston'}}]})
    def list_devices(selection = {:devices => "all"}, opts = {})
      query = Query.new(Search.new("devices", selection),
                        Find.new(opts[:limit]),
                        nil)
      Cursor.new(Device, remoter, "/v2/devices", query, media_types(:accept => [media_type("error", "v1"), media_type("device-collection", "v2")],
                                                                    :content => media_type("query", "v1")))
    end

    # Delete a device by key
    #
    # * +device_key+ [String] - The device key to delete by
    #
    # On succces:
    # - Return true if Device found, false if Device not found
    # On failure:
    # - Raises HttpException
    #
    # ==== Example
    #    # Delete device keyed 'heatpump4576'
    #    deleted = client.delete_device('heatpump4576')
    #    if deleted
    #      puts "Device was deleted"
    #    end
    def delete_device(device_key)
      result = remoter.delete("/v2/devices/#{URI.escape(device_key)}")
      case result.code
      when HttpResult::OK
        true
      when HttpResult::NOT_FOUND
        false
      else
        raise HttpException.new(result)
      end
    end

    # Delete a set of devices by Selection criteria
    #
    # * +selection+ - Device search criteria. See Selection.
    #
    # On success:
    # - Return a DeleteSummary object
    # On failure:
    # - Raises HttpException
    #
    # ==== Example
    #    # Delete all devices in building 'b4346'
    #    summary = client.delete_devices(:devices => {:attributes => {'building' => 'b4346'}})
    #    puts "Number of devices deleted: #{summary.deleted}"
    def delete_devices(selection)
      query = Query.new(Search.new("devices", selection),
                        Find.new,
                        nil)

      remoter.delete("/v2/devices", JSON.dump(query.to_hash)).on_success do |result|
        json = JSON.parse(result.body)
        DeleteSummary.new(json['deleted'])
      end
    end

    # Update a device
    #
    # * +device+ - Updated Device object.
    #
    # On success:
    # - Return updated Device on found, nil on Device not found
    # On failure:
    # - Raises HttpException
    #
    # ==== Example
    #
    #    # Get a device and update it's name
    #    device = client.get_device('building1234')
    #    if device
    #      device.name = "Updated name"
    #      client.update_device(device)
    #    end
    def update_device(device)
      remoter.put("/v2/devices/#{URI.escape(device.key)}", JSON.dump(device.to_hash)).on_success do |result|
        json = JSON.parse(result.body)
        Device.from_hash(json)
      end
    end

    # Write multiple datapoints to multiple device sensors. This function
    # is generally useful for importing data to many devices at once.
    #
    # * +bulk_write+ - The write request to send to the backend. Yielded to the block.
    #
    # On success:
    # - Returns MultiStatus
    # On partial success:
    # - Returns MultiStatus
    # On failure:
    # - Raises HttpException
    #
    # ==== Example
    #    # Write to 'device1' and 'device2' with different sensor readings
    #    status = client.write_bulk do |write|
    #      ts = Time.now
    #      write.add('device1', 'temp1', TempoIQ::DataPoint.new(ts, 1.23))
    #      write.add('device2', 'temp1', TempoIQ::DataPoint.new(ts, 2.34))
    #    end
    #
    #    if status.succes?
    #      puts "All datapoints written successfully"
    #    elsif status.partial_success?
    #      status.failures.each do |device_key, message|
    #        puts "Failed to write #{device_key}, message: #{message}"
    #      end
    #    end
    def write_bulk(bulk_write = nil, &block)
      bulk = bulk_write || BulkWrite.new
      if block_given?
        yield bulk
      elsif bulk_write.nil?
        raise ClientError.new("You must pass either a bulk write object, or provide a block")
      end

      result = remoter.post("/v2/write", JSON.dump(bulk.to_hash))
      if result.code == HttpResult::OK
        MultiStatus.new({})
      elsif result.code == HttpResult::MULTI
        json = JSON.parse(result.body)
        MultiStatus.new(json)
      else
        raise HttpException.new(result)
      end
    end

    # Write to multiple sensors in a single device, at the same timestamp. Useful for
    # 'sampling' from all the sensors on a device and ensuring that the timestamps align.
    #
    # * +device_key+ [String] - Device key to write to
    # * +ts+ [Time] - Timestamp that datapoints will be written at
    # * +values+ [Hash] - Hash from sensor_key => value
    #
    # On success:
    # - Return true
    # On failure:
    # - Raises HttpException
    #
    # ==== Example
    #
    #    ts = Time.now
    #    status = client.write_device('device1', ts, 'temp1' => 4.0, 'temp2' => 4.2)
    #    if status.succes?
    #      puts "All datapoints written successfully"
    #    end
    def write_device(device_key, ts, values)
      bulk = BulkWrite.new
      values.each do |sensor_key, value|
        bulk.add(device_key, sensor_key, DataPoint.new(ts, value))
      end
      write_bulk(bulk).success?
    end

    # Read from a set of Devices / Sensors, with an optional functional pipeline
    # to transform the values.
    #
    # * +selection+ [Selection] - Device selection, describes which Devices / Sensors we should operate on
    # * +start+ [Time] - Read start interval
    # * +stop+ [Time] - Read stop interval
    # * +pipeline+ [Pipeline] (optional)- Functional pipeline transformation. Supports analytic computation on a stream of DataPoints.
    #
    # On success:
    # - Return a Cursor of Row objects
    # On failure:
    # - Raise an HttpException
    #
    # ==== Examples
    #    # Read raw datapoints from Device 'bulding4567' Sensor 'temp1'
    #    start = Time.utc(2014, 1, 1)
    #    stop = Time.utc(2014, 1, 2)
    #    rows = client.read({:devices => {:key => 'building4567'}, :sensors => {:key => 'temp1'}}, start, stop)
    #    rows.each do |row|
    #      puts "Data at timestamp: #{row.ts}, value: #{row.value('building4567', 'temp1')}"
    #    end
    #
    #    # Find the daily mean temperature in Device 'building4567' across sensors 'temp1' and 'temp2'
    #    start = Time.utc(2014, 1, 1)
    #    stop = Time.utc(2014, 2, 2)
    #    rows = client.read({:devices => {:key => 'building4567'}, :sensors => {:key => 'temp1'}}, start, stop) do |pipeline|
    #      pipeline.rollup("1day", :mean, start)
    #      pipeline.aggregate(:mean)
    #    end
    #
    #    rows.each do |row|
    #      puts "Data at timestamp: #{row.ts}, value: #{row.value('building4567', 'temp1')}"
    #    end
    def read(selection, start, stop, pipeline = Pipeline.new, opts = {}, &block)
      if block_given?
        yield pipeline
      end

      query = Query.new(Search.new("devices", selection),
                        Read.new(start, stop, opts[:limit]),
                        pipeline)

      Cursor.new(Row, remoter, "/v2/read", query, media_types(:accept => [media_type("error", "v1"), media_type("datapoint-collection", "v2")],
                                                              :content => media_type("query", "v1")))
    end

    # Read the latest point from a set of Devices / Sensors, with an optional functional pipeline
    # to transform the values.
    #
    # * +selection+ [Selection] - Device selection, describes which Devices / Sensors we should operate on
    # * +pipeline+ [Pipeline] (optional)- Functional pipeline transformation. Supports analytic computation on a stream of DataPoints.
    #
    # On success:
    # - Return a Cursor of Row objects with only one Row inside
    # On failure:
    # - Raise an HttpException
    #
    # ==== Example
    #    # Find the latest DataPoints from Device 'bulding4567' Sensor 'temp1'
    #    rows = client.latest({:devices => {:key => 'building4567'}, :sensors => {:key => 'temp1'}})
    #    rows.each do |row|
    #      puts "Data at timestamp: #{row.ts}, value: #{row.value('building4567', 'temp1')}"
    #    end
    def latest(selection, pipeline = Pipeline.new, &block)
      if block_given?
        yield pipeline
      end

      query = Query.new(Search.new("devices", selection),
                        Single.new(:latest),
                        pipeline)

      Cursor.new(Row, remoter, "/v2/single", query)
    end

    # Read a single point from a set of Devices / Sensors, with an optional functional pipeline
    # to transform the values.
    #
    # * +selection+ [Selection] - Device selection, describes which Devices / Sensors we should operate on
    # * +function+ [Symbol] - The type of single point query to perform. One of:
    #   * :earliest - get the earliest points from the selection
    #   * :latest - get the latest points from the selection
    #   * :before - get the nearest points before the timestamp
    #   * :after - get the nearest points after the timestamp
    #   * :exact - get the points exactly at the timestamp if any
    #   * :nearest - get the nearest points to the timestamp
    # * +timestamp+ [Time] (optional)- Time, if any to apply the function to. Not necessary for earliest or latest.
    # * +pipeline+ [Pipeline] (optional)- Functional pipeline transformation. Supports analytic computation on a stream of DataPoints. 
    #
    # On success:
    # - Return a Cursor of Row objects with only one Row inside
    # On failure:
    # - Raise an HttpException
    #
    # ==== Example
    #    # Find the last DataPoint from Device 'bulding4567' Sensor 'temp1' before January 1, 2013
    #    rows = client.single({:devices => {:key => 'building4567'}, :sensors => {:key => 'temp1'}}, :before, Time.utc(2013, 1, 1))
    #    rows.each do |row|
    #      puts "Data at timestamp: #{row.ts}, value: #{row.value('building4567', 'temp1')}"
    #    end
    def single(selection, function, timestamp = nil, pipeline = Pipeline.new, &block)
      if block_given?
        yield pipeline
      end

      query = Query.new(Search.new("devices", selection),
                        Single.new(function, timestamp),
                        pipeline)

      Cursor.new(Row, remoter, "/v2/single", query, media_types(:accept => [media_type("error", "v1"), media_type("datapoint-collection", "v1")],
                                                                :content => media_type("query", "v1")))
    end

    # Delete datapoints by device and sensor key, start and stop date
    #
    # + *device_key* [String] - Device key to read from
    # + *sensor_key* [String] - Sensor key to read from
    # * +start+ [Time] - Read start interval
    # * +stop+ [Time] - Read stop interval
    #
    # On success:
    # _ Return a DeleteSummary describing the number of points deleted
    # On failure:
    # - Raise an HttpException
    #
    # ==== Example
    #     # Delete data from 'device1', 'temp' from 2013
    #     start = Time.utc(2013, 1, 1)
    #     stop = Time.utc(2013, 12, 31)
    #     summary = client.delete_datapoints('device1', 'temp', start, stop)
    #     puts "Deleted #{summary.deleted} points"
    def delete_datapoints(device_key, sensor_key, start, stop)
      delete_range = {:start => start.iso8601(3), :stop => stop.iso8601(3)}
      result = remoter.delete("/v2/devices/#{URI.escape(device_key)}/sensors/#{URI.escape(sensor_key)}/datapoints", JSON.dump(delete_range))
      case result.code
      when HttpResult::OK
        json = JSON.parse(result.body)
        DeleteSummary.new(json['deleted'])
      else
        raise HttpException.new(result)
      end
    end

    # Convenience function to read from a single Device, and single Sensor
    #
    # + *device_key* [String] - Device key to read from
    # + *sensor_key* [String] - Sensor key to read from
    # * +start+ [Time] - Read start interval
    # * +stop+ [Time] - Read stop interval
    # * +pipeline+ [Pipeline] (optional)- Functional pipeline transformation. Supports analytic computation on a stream of DataPoints.
    #
    # On success:
    # - Return a Cursor of DataPoint objects.
    # On failure:
    # - Raise an HttpException
    #
    # ==== Example
    #     # Read from 'device1', 'temp1'
    #     start = Time.utc(2014, 1, 1)
    #     stop = Time.utc(2014, 1, 2)
    #     datapoints = client.read_device_sensor('device1', 'temp1', start, stop)
    #     datapoints.each do |point|
    #       puts "DataPoint ts: #{point.ts}, value: #{point.value}"
    #     end
    def read_device_sensor(device_key, sensor_key, start, stop, pipeline = nil, &block)
      selection = {:devices => {:key => device_key}, :sensors => {:key => sensor_key}}
      read(selection, start, stop, pipeline).map do |row|
        sub_key = row.values.map { |device_key, sensors| sensors.keys.first }.first || sensor_key
        DataPoint.new(row.ts, row.value(device_key, sub_key))
      end
    end

    private

    def media_types(types)
      {
        "Accept" => types[:accept],
        "Content-Type" => types[:content]
      }
    end

    def media_type(media_resource, media_version, suffix = "json")
      "#{MEDIA_PREFIX}.#{media_resource}.#{media_version}+#{suffix}"
    end
  end
end

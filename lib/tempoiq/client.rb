require 'json'
require 'uri'

require 'tempoiq/models/bulk_write'
require 'tempoiq/models/cursor'
require 'tempoiq/models/datapoint'
require 'tempoiq/models/delete_summary'
require 'tempoiq/models/device'
require 'tempoiq/models/selection'

require 'tempoiq/remoter/live_remoter'

module TempoIQ
  class Client
    attr_reader :key, :secret, :host, :secure, :remoter

    def initialize(key, secret, host, port = 443, opts = {})
      @key = key
      @secret = secret
      @host = host
      @port = port
      @secure = opts.has_key?(:secure) ? opts[:secure] : true
      @remoter = opts[:remoter] || LiveRemoter.new(key, secret, host, port, secure)
    end
    
    def create_device(key, name, attributes, sensors = [])
      device = Device.new(key, name, attributes, *sensors)
      remoter.post("/v2/devices", JSON.dump(device.to_hash)).on_success do |result|
        json = JSON.parse(result.body)
        Device.from_hash(json)
      end
    end

    def get_device(device_key)
      remoter.get("/v2/devices/#{URI.escape(device_key)}").on_success do |result|
        json = JSON.parse(result.body)
        Device.from_hash(json)
      end
    end

    def list_devices(selection)
      Cursor.new(Device, remoter, "/v2/devices", Selection.new("devices", selection))
    end

    def delete_device(device_key)
      remoter.delete("/v2/devices/#{URI.escape(device_key)}")
    end

    def delete_devices(selection)
      remoter.delete("/v2/devices", JSON.dump(Selection.new("devices", selection).to_hash)).on_success do |result|
        json = JSON.parse(result.body)
        DeleteSummary.new(json['deleted'])
      end
    end

    def update_device(device)
      remoter.put("/v2/devices/#{URI.escape(device.key)}", JSON.dump(device.to_hash)).on_success do |result|
        json = JSON.parse(result.body)
        Device.from_hash(json)
      end
    end

    def write_bulk(&block)
      bulk = BulkWrite.new
      yield bulk
      remoter.post("/v2/write", JSON.dump(bulk.to_hash))
    end
  end
end

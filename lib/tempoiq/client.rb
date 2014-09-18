require 'json'

require 'tempoiq/models/device'

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
      device = Device.new(key, name, attributes, sensors)
      remoter.post("/v2/devices", JSON.dump(device.to_hash)).on_success do |result|
        json = JSON.parse(result.body)
        Device.new(json['key'], json['name'], json['attributes'], json['sensors'])
      end
    end
  end
end

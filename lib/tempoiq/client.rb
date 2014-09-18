module TempoIQ
  class Client
    attr_reader :key, :secret, :host, :secure

    def initialize(key, secret, host, secure = true)
      @key = key
      @secret = secret
      @host = host
      @secure = secure
    end
    
    
  end
end

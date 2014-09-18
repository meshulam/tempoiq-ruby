module TempoIQ
  class LiveRemoter
    def initialize(key, secret, host, secure)
      @key = key
      @secret = secret
      @host = host
      @secure = secure
    end

    def post(route, body, headers = {})
    end
  end
end

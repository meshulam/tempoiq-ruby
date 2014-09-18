module TempoIQ
  class HttpResult
    attr_reader :code, :headers, :body

    def initialize(code, headers, body)
      @code = code
      @headers = headers
      @body = body
    end

    def on_success(&block)
      if code / 100 == 2
        yield self
      end
    end
  end
end

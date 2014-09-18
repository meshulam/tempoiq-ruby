module TempoIQ
  class HttpException < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
    end
  end

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
      else
        raise HttpException.new(self), "HTTP returned non-success response: #{code}"
      end
    end
  end
end

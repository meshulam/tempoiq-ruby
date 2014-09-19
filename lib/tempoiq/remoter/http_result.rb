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
      if success?
        yield self
      else
        raise HttpException.new(self), "HTTP returned non-success response: #{code}, #{body}"
      end
    end

    def success?
      code / 100 == 2
    end
  end
end

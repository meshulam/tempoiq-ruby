module TempoIQ
  class HttpException < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
    end
  end

  class HttpResult
    OK = 200
    MULTI = 207
    BAD_REQUEST = 400
    UNAUTHORIZED = 401
    NOT_FOUND = 404
    UNPROCESSABLE = 422
    INTERNAL = 500

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

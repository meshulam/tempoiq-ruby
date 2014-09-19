require 'httpclient'

require 'tempoiq/constants'
require 'tempoiq/remoter/http_result'

module TempoIQ
  class LiveRemoter
    BASE_HEADERS = {
      'User-Agent' => "tempoiq-ruby/#{TempoIQ::Constants::VERSION}",
      'Accept-Encoding' => "gzip"
    }

    def initialize(key, secret, host, port, secure)
      @key = key
      @secret = secret
      @host = host
      @port = port
      @secure = secure
      @http_client = HTTPClient.new
      @http_client.transparent_gzip_decompression = true
      @http_client.set_auth(nil, key, secret)
      if secure
        @http_client.ssl_config.clear_cert_store
        @http_client.ssl_config.set_trust_ca(TempoIQ::Constants::TRUSTED_CERT_FILE)
      end
    end

    def get(route, body = nil, headers = {})
      execute_http(:get, build_uri(route),
                   :headers => BASE_HEADERS.merge(headers),
                   :body => body)
    end

    def post(route, body = nil, headers = {})
      execute_http(:post, build_uri(route),
                   :headers => BASE_HEADERS.merge(headers),
                   :body => body)
    end

    def put(route, body = nil, headers = {})
      execute_http(:put, build_uri(route),
                   :headers => BASE_HEADERS.merge(headers),
                   :body => body)
    end

    def delete(route, body = nil, headers = {})
      execute_http(:delete, build_uri(route),
                   :headers => BASE_HEADERS.merge(headers),
                   :body => body)
    end

    def stub(*args)
      # Live client. No op.
    end

    private

    def execute_http(method, uri, *args)
      response = @http_client.request(method, uri, *args)
      HttpResult.new(response.code, response.headers, response.body)
    end

    def build_uri(route, query = {})
      scheme = if @secure then "https" else "http" end
      params = nil # TODO: Generate real query params
      URI::HTTP.new(scheme, nil, @host, @port, nil, route, nil, params, nil)
    end
  end
end

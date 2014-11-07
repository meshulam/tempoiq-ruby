require 'digest/sha1'

require 'tempoiq/remoter/http_result'

module TempoIQ
  class StubbedRemoter
    def initialize(pop_stubs = false)
      @active_stubs = Hash.new do |stubs, key|
        stubs[key] = []
      end
      @pop_stubs = pop_stubs
    end

    def stub(http_verb, route, code, body = nil, headers = {})
      @active_stubs[key_for(http_verb, route)] << {
        :body => body,
        :code => code,
        :headers =>headers
      }
    end

    def get(route, body = nil, headers = {})
      return_stub(:get, route, body, headers)
    end

    def post(route, body = nil, headers = {})
      return_stub(:post, route, body, headers)
    end

    def delete(route, body = nil, headers = {})
      return_stub(:delete, route, body, headers)
    end

    def put(route, body = nil, headers = {})
      return_stub(:put, route, body, headers)
    end

    private

    def key_for(http_verb, route)
      Digest::SHA1.hexdigest(http_verb.to_s+route)
    end

    def return_stub(http_verb, route, body, headers)
      stubs = @active_stubs[key_for(http_verb, route)]
      if stubs.empty?
        raise "Real HTTP Connections are not allowed. #{http_verb} #{route} didn't match any active stubs"
      else
        stub = @pop_stubs ? stubs.shift : stubs.first
        HttpResult.new(stub[:code], stub[:headers], stub[:body])
      end
    end
  end
end

require 'enumerator'
require 'json'

module TempoIQ
  class Cursor
    attr_reader :remoter, :route, :selection, :segment_key

    include Enumerable

    def initialize(klass, remoter, route, selection, segment_key = "data")
      @klass = klass
      @remoter = remoter
      @route = route
      @selection = selection
      @segment_key = segment_key
      @segment = nil
    end

    def each
      get_segment! if @segment.nil?
      @segment.each { |item| yield @klass.from_hash(item) }
    end

    private

    def get_segment!
      remoter.get(route, JSON.dump(selection.to_hash)).on_success do |result|
        json = JSON.parse(result.body)
        @segment = json[segment_key]
      end
    end
  end
end

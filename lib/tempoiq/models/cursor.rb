require 'enumerator'
require 'json'

module TempoIQ
  # Cursor is an abstraction over a sequence / stream of objects. It
  # uses lazy iteration to transparently fetch segments of data from
  # the server.
  #
  # It implements the Enumerable interface, which means convenience functions
  # such as Enumerable#to_a are available if you know you're working with a 
  # small enough segment of data that can reasonably fit in memory.
  class Cursor
    attr_reader :remoter, :route, :query, :segment_key

    include Enumerable

    def initialize(klass, remoter, route, query, segment_key = "data")
      @klass = klass
      @remoter = remoter
      @route = route
      @query = query
      @segment_key = segment_key
      @segment = nil
    end

    def each
      get_segment! if @segment.nil?
      @segment.each { |item| yield @klass.from_hash(item) }
    end

    private

    def get_segment!
      remoter.get(route, JSON.dump(query.to_hash)).on_success do |result|
        json = JSON.parse(result.body)
        @segment = json[segment_key]
      end
    end
  end
end

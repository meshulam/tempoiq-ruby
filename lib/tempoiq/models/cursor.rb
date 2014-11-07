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
    PAGE_LINK = "next_page"
    NEXT_QUERY = "next_query"

    attr_reader :remoter, :route, :query, :segment_key

    include Enumerable

    def initialize(klass, remoter, route, query, segment_key = "data")
      @klass = klass
      @remoter = remoter
      @route = route
      @query = query
      @segment_key = segment_key
    end

    def each
      segment = nil
      until segment == nil && query == nil do
        json = get_segment(JSON.dump(query.to_hash))
        segment = json[segment_key]
        segment.each { |item| yield @klass.from_hash(item) }
        segment = nil
        @query = json.fetch(PAGE_LINK, {})[NEXT_QUERY]
      end
    end

    private

    def get_segment(next_query)
      remoter.get(route, next_query).on_success do |result|
        JSON.parse(result.body)
      end
    end
  end
end

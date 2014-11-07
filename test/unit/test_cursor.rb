require 'test/unit'
require 'json'
require 'time'

require 'tempoiq/remoter/stubbed_remoter'

require 'tempoiq/models/cursor'
require 'tempoiq/models/pipeline'
require 'tempoiq/models/search'
require 'tempoiq/models/query'
require 'tempoiq/models/read'
require 'tempoiq/models/row'

class CursorTest < Test::Unit::TestCase
  def test_simple_datapoint_cursoring
    remoter = TempoIQ::StubbedRemoter.new(true)
    start = Time.utc(2012, 1, 1)
    stop = Time.utc(2012, 1, 2)
    query = TempoIQ::Query.new(TempoIQ::Search.new("devices", {:devices => :all}),
                               TempoIQ::Read.new(start, stop),
                               TempoIQ::Pipeline.new)

    stubbed_read = {
      "data" => [
                 {
                   "t" => start.iso8601(3),
                   "data" => {
                     'device1' => {
                       'sensor1' => 4.0,
                       'sensor2' => 2.0
                     }
                   }
                 }
                ]
    }
    remoter.stub(:get, "/v2/read", 200, JSON.dump(stubbed_read))

    cursor = TempoIQ::Cursor.new(TempoIQ::Row, remoter, "/v2/read", query)
    rows = cursor.to_a
    assert_equal(1, rows.size)
  end

  def test_datapoint_cursoring_two_pages
    remoter = TempoIQ::StubbedRemoter.new(true)
    start = Time.utc(2012, 1, 1)
    middle = start + 100
    stop = Time.utc(2012, 1, 2)
    query = TempoIQ::Query.new(TempoIQ::Search.new("devices", {:devices => :all}),
                               TempoIQ::Read.new(start, stop),
                               TempoIQ::Pipeline.new)

    next_query = query.to_hash
    next_query['read']['start'] = middle.iso8601(3)
    first_read = {
      "data" => [
                 {
                   "t" => middle.iso8601(3),
                   "data" => {
                     'device1' => {
                       'sensor1' => 4.0,
                       'sensor2' => 2.0
                     }
                   }
                 }
                ],
      "next_page" => {
        "next_query" => next_query
      }
    }
    remoter.stub(:get, "/v2/read", 200, JSON.dump(first_read))

    next_read = first_read
    next_read.delete("next_page")
    next_read["data"][0]["t"] = stop.iso8601(3)
    remoter.stub(:get, "/v2/read", 200, JSON.dump(next_read))

    cursor = TempoIQ::Cursor.new(TempoIQ::Row, remoter, "/v2/read", query)
    rows = cursor.to_a
    assert_equal(2, rows.size)
  end

  def test_datapoint_cursoring_error
    remoter = TempoIQ::StubbedRemoter.new(true)
    start = Time.utc(2012, 1, 1)
    middle = start + 100
    stop = Time.utc(2012, 1, 2)
    query = TempoIQ::Query.new(TempoIQ::Search.new("devices", {:devices => :all}),
                               TempoIQ::Read.new(start, stop),
                               TempoIQ::Pipeline.new)

    next_query = query.to_hash
    next_query['read']['start'] = middle.iso8601(3)
    first_read = {
      "data" => [
                 {
                   "t" => middle.iso8601(3),
                   "data" => {
                     'device1' => {
                       'sensor1' => 4.0,
                       'sensor2' => 2.0
                     }
                   }
                 }
                ],
      "next_page" => {
        "next_query" => next_query
      }
    }
    remoter.stub(:get, "/v2/read", 200, JSON.dump(first_read))
    remoter.stub(:get, "/v2/read", 500)

    assert_raise TempoIQ::HttpException do
      TempoIQ::Cursor.new(TempoIQ::Row, remoter, "/v2/read", query).to_a
    end
  end
end

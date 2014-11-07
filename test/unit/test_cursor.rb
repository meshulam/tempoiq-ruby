require 'test/unit'
require 'json'

require 'tempoiq/remoter/stubbed_remoter'

require 'tempoiq/models/cursor'
require 'tempoiq/models/pipeline'
require 'tempoiq/models/search'
require 'tempoiq/models/read'
require 'tempoiq/models/row'

class CursorTest < Test::Unit::TestCase
  def test_simple_datapoint_cursoring
    remoter = TempoIQ::StubbedRemoter.new
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
end

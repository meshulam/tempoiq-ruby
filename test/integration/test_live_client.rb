require 'yaml'
require 'test/unit'

require File.join(File.dirname(__FILE__), "..", "client_test")

require 'tempoiq/remoter/live_remoter'

class TestLiveClient < Test::Unit::TestCase
  include ClientTest

  private

  def get_client
    file = File.read(File.join(File.dirname(__FILE__), "integration-credentials.yml"))
    creds = YAML.load(file)
    TempoIQ::Client.new(creds["key"], creds["secret"], creds["hostname"], creds["port"],
                        :secure => creds["secure"])
  end
end

module TempoIQ
  class DeleteSummary
    attr_reader :deleted

    def initialize(deleted)
      @deleted = deleted
    end
  end
end

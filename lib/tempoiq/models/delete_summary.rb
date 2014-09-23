module TempoIQ
  # When deleting multiple objects from a TempoIQ backend, return
  # information about what was actually deleted.
  class DeleteSummary
    # Number of objects deleted in the call
    attr_reader :deleted

    def initialize(deleted)
      @deleted = deleted
    end
  end
end

module ActiveMemory
  module Errors
    class ActiveMemoryError < StandardError; end
    class RecordInvalid < ActiveMemoryError; end
  end
end

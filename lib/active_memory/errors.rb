module ActiveMemory
  module Errors
    class ActiveMemoryError < StandardError; end
    class RecordInvalid < ActiveMemoryError; end
    class RecordNotFound < ActiveMemoryError; end
  end
end

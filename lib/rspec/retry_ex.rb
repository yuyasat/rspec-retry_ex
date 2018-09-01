require "rspec/retry_ex/retry_handler"

module RSpec
  module RetryEx
    def retry_ex(**options)
      handler = RetryHandler.new(options)
      handler.run do
        yield
      end
    end
  end
end

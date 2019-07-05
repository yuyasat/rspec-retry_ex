require "rspec/core"
require "rspec/retry_ex/retry_handler"

module RSpec
  module RetryEx
    def self.setup
      RSpec.configure do |config|
        config.add_setting :rspec_retry_ex_retry_errors, default: []
      end
    end

    def retry_ex(**options)
      handler = RetryHandler.new(options)
      handler.run do
        yield
      end
    end
  end
end

RSpec::RetryEx.setup

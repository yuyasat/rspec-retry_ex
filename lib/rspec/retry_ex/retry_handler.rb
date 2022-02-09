module RSpec
  module RetryEx
    class RetryHandler
      def initialize(**options)
        @count        = options[:count] || 1
        @before_retry = options[:before_retry]
        @after_retry  = options[:after_retry]
        @counter      = 0
        @retry_errors = initialize_retry_errors(options[:retry_errors])
      end

      def run
        call_around_retry(before_retry) if @counter > 0
        @counter += 1
        yield
        success_message
      rescue *@retry_errors => e
        call_around_retry(after_retry)
        failure_message(e, count)
        retry if @counter < count
        raise e
      end

      private

      attr_reader :count, :before_retry, :after_retry

      def call_around_retry(around_retry)
        return if around_retry.nil?

        around_retry.call
      end

      def success_message
        return unless @counter > 1

        message = "Congratulations! #{ordinalize(@counter)} try has succeeded!.\n"
        RSpec.configuration.reporter.message(message)
      end

      def failure_message(error, count)
        message = "#{ordinalize(@counter)} try has failed.\n"
        message += "=>#{error}" if @counter == count
        RSpec.configuration.reporter.message(message)
      end

      # borrowed from ActiveSupport::Inflector
      # rubocop:disable Metrics/MethodLength
      def ordinalize(number)
        case number
        when 1 then "1st"
        when 2 then "2nd"
        when 3 then "3rd"
        when 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 then "#{number}th"
        else
          num_modulo = number.to_i.abs % 100
          num_modulo %= 10 if num_modulo > 13
          case num_modulo
          when 1 then "#{number}st"
          when 2 then "#{number}nd"
          when 3 then "#{number}rd"
          else        "#{number}th"
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def initialize_retry_errors(retry_errors)
        if retry_errors.is_a?(Array) && !retry_errors.empty?
          retry_errors
        elsif !RSpec.configuration.rspec_retry_ex_retry_errors.empty?
          RSpec.configuration.rspec_retry_ex_retry_errors
        else
          [RSpec::Expectations::ExpectationNotMetError]
        end
      end
    end
  end
end

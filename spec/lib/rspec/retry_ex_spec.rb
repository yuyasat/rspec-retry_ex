require "spec_helper"

describe RSpec::RetryEx do
  def count
    @count ||= 0
    @count
  end

  def count_up
    @count ||= 0
    @count += 1
  end

  describe "Try Count" do
    context "when test passes" do
      it "should not retry" do
        retry_ex(count: 2) do
          count_up
          expect(true).to eq true
        end
        expect(count).to eq 1
      end
    end

    context "when test fails" do
      let(:retry_count) { 2 }

      it "should retry" do
        # rubocop:disable Lint/HandleExceptions
        begin
          retry_ex(count: retry_count) do
            count_up
            expect(true).to eq false
          end
        rescue RSpec::Expectations::ExpectationNotMetError
        end
        # rubocop:enable Lint/HandleExceptions

        expect(count).to eq retry_count
      end
    end
  end

  describe "Error" do
    context "when test passes" do
      it "should not raise RSpec::Expectations::ExpectationNotMetError" do
        expect {
          retry_ex(count: 2) do
            expect(true).to eq true
          end
        }.not_to raise_error
      end
    end

    context "when test fails" do
      it "should raise RSpec::Expectations::ExpectationNotMetError" do
        expect {
          retry_ex(count: 2) do
            expect(true).to eq false
          end
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end
  end

  describe "Error message" do
    before { allow_any_instance_of(RSpec::Core::Reporter).to receive(:message) }

    context "when test passes" do
      it "should have messages" do
        expect_any_instance_of(RSpec::Core::Reporter).not_to receive(:message)

        retry_ex(count: 2) do
          expect(true).to eq true
        end
      end
    end

    context "when test fails" do
      it "should have messages" do
        expect_any_instance_of(RSpec::Core::Reporter).to receive(:message).with(
          "1st try has failed.\n"
        )
        expect_any_instance_of(RSpec::Core::Reporter).to receive(:message).with(<<~MESSAGE.chomp)
          2nd try has failed.
          =>
          expected: false
               got: true

          (compared using ==)

          Diff:\e[0m
          \e[0m\e[34m@@ -1 +1 @@
          \e[0m\e[31m-false
          \e[0m\e[32m+true
          \e[0m
        MESSAGE
        # rubocop:disable Lint/HandleExceptions
        begin
          retry_ex(count: 2) do
            expect(true).to eq false
          end
        rescue RSpec::Expectations::ExpectationNotMetError
        end
        # rubocop:enable Lint/HandleExceptions
      end
    end

    context "when 1st test fails and 2nd test passes" do
      it "should have messages" do
        expect_any_instance_of(RSpec::Core::Reporter).to receive(:message).with(
          "1st try has failed.\n"
        )
        expect_any_instance_of(RSpec::Core::Reporter).to receive(:message).with(
          "Congratulations! 2nd try has succeeded!.\n"
        )

        retry_ex(count: 2) do
          count_up
          expect(count).to eq 2
        end
      end
    end
  end

  describe "customize retry_errors" do
    context "when no configuration" do
      it "should raise error" do
        expect {
          retry_ex(count: 2) do
            1 / 0
          end
        }.to raise_error(ZeroDivisionError)
      end
    end

    context "when rescue ZeroDivisionError with configulation" do
      before do
        RSpec.configuration.rspec_retry_ex_retry_errors = [ZeroDivisionError]
      end

      after do
        RSpec.configuration.rspec_retry_ex_retry_errors = []
      end

      let(:retry_count) { 2 }

      it "should not raise error and count_up" do
        # rubocop:disable Lint/HandleExceptions
        begin
          retry_ex(count: retry_count) do
            count_up
            1 / 0
          end
        rescue ZeroDivisionError
        end
        # rubocop:enable Lint/HandleExceptions

        expect(count).to eq retry_count
      end
    end

    context "when rescue ZeroDivisionError as retry_ex options" do
      let(:retry_count) { 2 }

      it "should not raise error and count_up" do
        # rubocop:disable Lint/HandleExceptions
        begin
          retry_ex(count: retry_count, retry_errors: [ZeroDivisionError]) do
            count_up
            1 / 0
          end
        rescue ZeroDivisionError
        end
        # rubocop:enable Lint/HandleExceptions

        expect(count).to eq retry_count
      end
    end
  end

  describe "before_retry/after_retry" do
    let(:mock) { double("Before Retry Mock") }
    let(:around_retry) { -> { mock.some_method } }

    before do
      allow(mock).to receive(:some_method)
    end

    describe "before_retry" do
      context "when 1st, 2nd, 3rd test fails and 4th test passes" do
        it "should call some_method" do
          expect(mock).to receive(:some_method).exactly(3).times

          retry_ex(count: 4, before_retry: around_retry) do
            count_up
            expect(count).to eq 4
          end
        end
      end
    end

    describe "after_retry" do
      context "when 1st, 2nd, 3rd test fails and 4th test passes" do
        it "should call some_method" do
          expect(mock).to receive(:some_method).exactly(3).times

          retry_ex(count: 4, after_retry: around_retry) do
            count_up
            expect(count).to eq 4
          end
        end
      end
    end
  end
end

require "spec_helper"

describe RSpec::RetryEx::RetryHandler do
  describe "#ordinalize" do
    subject { RSpec::RetryEx::RetryHandler.new.__send__(:ordinalize, number) }

    [
      { number: 1, ordinalized: "1st" },
      { number: 2, ordinalized: "2nd" },
      { number: 3, ordinalized: "3rd" },
      { number: 4, ordinalized: "4th" },
      { number: 10, ordinalized: "10th" },
      { number: 11, ordinalized: "11th" },
      { number: 1002, ordinalized: "1002nd" },
      { number: 1003, ordinalized: "1003rd" },
    ].each do |hoge|
      context "when number is #{hoge[:number]}" do
        let(:number) { hoge[:number] }
        it { is_expected.to eq hoge[:ordinalized] }
      end
    end
  end
end

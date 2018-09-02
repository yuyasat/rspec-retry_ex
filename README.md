# RSpec::RetryEx
[![Build Status](https://travis-ci.org/yuyasat/rspec-retry_ex.svg?branch=master)](https://travis-ci.org/yuyasat/rspec-retry_ex)
[![Maintainability](https://api.codeclimate.com/v1/badges/e5524b7a5cd965dd362e/maintainability)](https://codeclimate.com/github/yuyasat/rspec-retry_ex/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/e5524b7a5cd965dd362e/test_coverage)](https://codeclimate.com/github/yuyasat/rspec-retry_ex/test_coverage)

RSpec::RetryEx retrys failing rspec "expect" instead of "example", "it" or "scenario".

## Motivation
Feature test or System test sometimes fails randomely. There are so many reasons for failing. One of them is that the browser does not response smoothly to JavaScript animation. However it responses somoothly in a few tries. As a result, a few retries should be executed in feature test of system test.

Thanks to [spec-retry](https://github.com/NoRedInk/rspec-retry) gem, a few retries can be executed by "scenario" unit. However we sometimes want to try to retry by "expect" unit because the scenario is so long and most "expect"s usually pass and specific "expect" often fails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-retry_ex'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-retry_ex

require in spec_helper.rb or rails_helper.rb

```ruby
include RSpec::RetryEx
```

## Usage

Surround target "expect" with `retry_ex` method.

```ruby
scenario "Some scenario" do
  visit "/some_page"

  fill_in "postcode", with: "1300012"
  retry_ex(count: 3) do
    expect(page).to have_select("ward", selected: "Sumida")
  end
end
```

Some codes can be added when the test fails with "before_retry" or "after_retry" option.

```ruby
scenario "Some scenario" do
  visit "/some_page"

  fill_in "postcode", with: "1300012"

  # These codes are executed after the retry fails
  after_retry = -> {
    fill_in "postcode", with: "1000004"
    fill_in "postcode", with: "1300012"
  }
  retry_ex(count: 3, after_retry: after_retry) do
    expect(page).to have_select("ward", selected: "Sumida")
  end
end
```

## Contributing
You should follow the steps below:

1. Fork the repository
2. Create a feature branch: `git checkout -b add-new-feature`
3. Commit your changes: `git commit -am 'Add new feature'`
4. Push the branch: `git push origin add-new-feature`
4. Send us a pull request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

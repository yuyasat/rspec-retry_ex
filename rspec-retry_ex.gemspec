
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rspec/retry_ex/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-retry_ex"
  spec.version       = RSpec::RetryEx::VERSION
  spec.authors       = ["yuyasat"]
  spec.email         = ["yuya.taki@users.noreply.github.com"]

  spec.summary       = "retry rspec one target `expect`"
  spec.description   = "retry rspec one target `expect` instead of one `secenario` or `it`"
  spec.homepage      = "https://github.com/yuyasat/rspec-retry_ex"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency(%{rspec-core}, '>3.3')
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "simplecov"
end

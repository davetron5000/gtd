require 'simplecov'
ENV["GTD_ENV"] ||= "test"
if ENV["GTD_ENV"] != "test"
  raise "Can't run tests in environment #{ENV["GTD_ENV"]}"
end
SimpleCov.command_name "RSpec unit tests"
SimpleCov.start do
  command_name "Unit Tests"
  add_filter "/spec/"
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = false

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random
  Kernel.srand config.seed
end

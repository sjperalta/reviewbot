require "bundler/setup"

Bundler.require(:default, :development)

require "webmock/rspec"
require "vcr"

Dir[File.join(__dir__, "..", "lib", "**", "*.rb")].sort.each { |f| require f }

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = File.join(__dir__, "fixtures", "vcr_cassettes")
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed

  config.before(:each) do
    allow(Reviewbot::Utils::Logger).to receive(:info).and_return(nil)
    allow(Reviewbot::Utils::Logger).to receive(:debug).and_return(nil)
    allow(Reviewbot::Utils::Logger).to receive(:warn).and_return(nil)
    allow(Reviewbot::Utils::Logger).to receive(:error).and_return(nil)
  end
end

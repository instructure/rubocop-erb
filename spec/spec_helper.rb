# frozen_string_literal: true

require 'rubocop-erb'
require 'rubocop-rails'
require 'rubocop/rspec/support'
require 'rubocop/rspec/erb/support'
require 'debug'

# Optional-dependency cop patches are normally applied from the plugin's `rules`
# hook during a real run; apply them here so the specs exercise them too.
RuboCop::Erb::Plugin.patch_optional_cops

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.filter_run_when_matching :focus
end

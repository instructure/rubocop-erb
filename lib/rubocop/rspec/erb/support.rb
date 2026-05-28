# frozen_string_literal: true

require_relative 'cop_helper'

RSpec.configure do |config|
  config.include RuboCop::RSpec::ERB::CopHelper
end

# frozen_string_literal: true

require 'rubocop'

module RuboCop
  module Erb
    autoload :ERBSource, 'rubocop/erb/erb_source'
    autoload :RubyExtractor, 'rubocop/erb/ruby_extractor'
  end
end

require_relative 'rubocop/erb/version'
require_relative 'rubocop/erb/plugin'
require_relative 'rubocop/erb/corrector'
require_relative 'rubocop/cop/erb_cops'

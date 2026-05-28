# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module Erb
    # A plugin that integrates rubocop-erb with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      # Patches for cops that live in optional dependencies (e.g. rubocop-rails).
      #
      # This runs from `rules` rather than at require time because RuboCop
      # requires every plugin's library before integrating any plugin's rules, so
      # the optional cops are guaranteed to be loaded here if they are in use --
      # regardless of the order rubocop-erb and the other plugin load in.
      def self.patch_optional_cops
        return unless defined?(RuboCop::Cop::Rails::Presence)

        RuboCop::Cop::Rails::Presence.prepend(RuboCop::Cop::ERB::IgnoreAcrossERBNodes)
      end

      def about
        LintRoller::About.new(
          description: 'RuboCop plugin for ERB template.',
          homepage: 'https://github.com/r7kamura/rubocop-erb',
          name: 'rubocop-erb',
          version: VERSION
        )
      end

      def rules(_context)
        RuboCop::Runner.ruby_extractors.unshift(RuboCop::Erb::RubyExtractor)
        self.class.patch_optional_cops

        LintRoller::Rules.new(
          config_format: :rubocop,
          type: :path,
          value: Pathname.new(__dir__).join('../../../config/default.yml')
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end
    end
  end
end

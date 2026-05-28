# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      module Lint
        module Syntax
          def add_offense_from_diagnostic(
            diagnostic,
            _ruby_version
          )
            return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

            add_offense(diagnostic.location, message: diagnostic.message, severity: diagnostic.level)
          end
        end
      end
    end
  end
end

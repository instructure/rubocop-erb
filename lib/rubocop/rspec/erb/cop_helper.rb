# frozen_string_literal: true

module RuboCop
  module RSpec
    module ERB
      module CopHelper
        # overwritten to pass original source through
        def _investigate(
          cop,
          processed_source
        )
          team = RuboCop::Cop::Team.new([cop], configuration, raise_error: true)
          report = team.investigate(processed_source, original: @original_processed_source)
          @last_corrector = team.send(:collate_corrections, report, offset: 0, original: @original_processed_source)
          report.offenses.reject(&:disabled?)
        end

        def parse_source(
          source,
          file = nil
        )
          processed_source = super
          @original_processed_source = processed_source

          if processed_source.path&.end_with?('.erb')
            processed_source = RuboCop::Erb::RubyExtractor.call(processed_source)&.first&.fetch(:processed_source)
          end
          processed_source
        end
      end
    end
  end
end

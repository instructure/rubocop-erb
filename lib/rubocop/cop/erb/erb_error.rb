# frozen_string_literal: true

module RuboCop
  module Cop
    module ERB
      # This is not a class inheriting from Base, because it's abstract and RuboCop doesn't
      # deal with that gracefully. So instead it's a module that's automatically mixed in
      # when a new child class is defined using the `define` class method.
      module ERBError
        include HerbLocationHelper

        @registered_error_classes = []

        class << self
          def define(
            erb_error_class,
            &block
          )
            @registered_error_classes << erb_error_class
            Class.new(Base) do
              include ERBError

              class << self
                attr_reader :erb_error_class
              end

              @erb_error_class = erb_error_class
              class_eval(&block) if block_given?
            end
          end
        end

        def format_message(error)
          error.message
        end

        def on_new_investigation
          return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

          processed_source.herb_parse_result.errors.each do |error|
            next unless error.instance_of?(self.class.erb_error_class)

            add_offense(error.location, message: format_message(error))
          end

          super
        end
      end

      InconsistentControlFlowScope = ERBError.define(Herb::Errors::ERBControlFlowScopeError)
      MissingClosingTag = ERBError.define(Herb::Errors::MissingClosingTagError)
      MissingOpeningTag = ERBError.define(Herb::Errors::MissingOpeningTagError)
      MultipleBlocksInTag = ERBError.define(Herb::Errors::ERBMultipleBlocksInTagError)
      OmittedClosingTag = ERBError.define(Herb::Errors::OmittedClosingTagError) do
        def format_message(error)
          error.message.sub(/, or set `strict: false` to allow this\.\z/, '.')
        end
      end
      StrayClosingTag = ERBError.define(Herb::Errors::StrayERBClosingTagError)
      VoidElementWithClosingTag = ERBError.define(Herb::Errors::VoidElementClosingTagError)

      module ERBError
        NON_SYNTAX_ERROR_CLASSES = @registered_error_classes.freeze
      end
    end
  end
end

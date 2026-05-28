# frozen_string_literal: true

require 'herb'

module RuboCop
  module Cop
    module ERBVisitor
      include HerbLocationHelper

      VISITOR_METHODS = Herb::Visitor.instance_methods.grep(/^visit_/).freeze
      private_constant :VISITOR_METHODS

      def on_new_investigation
        return super unless processed_source.is_a?(RuboCop::Erb::ERBSource)

        @visitor = Visitor.new(self)
        @visitor.visit(processed_source.erb_root)

        super
      end

      # Herb::Visitor is a class, and can't be mixed in, but we still want its implementation.
      # So we have an internal visitor class that just calls back to the cop for every method,
      # and then we define a default implementation in the cop that calls back to the visitor
      # with a special kwarg that tells it to call Herb::Visitor's implementation instead of
      # the cop's implementation. This allows `super` to work on any visitor methods defined
      # in the cop's class just like it was part of the visitor.
      VISITOR_METHODS.each do |method_name|
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{method_name}(node)                           # def visit_erb_node(node)
            @visitor.#{method_name}(node, call_super: true)  #   visitor.visit_erb_node(node, call_super: true)
          end                                                # end
        RUBY
      end

      class Visitor < Herb::Visitor
        def initialize(cop)
          @cop = cop
          super()
        end

        VISITOR_METHODS.each do |method_name|
          # call_super is only set by ERBVisitor, allowing us to distinguish between calls
          # originating from the cop (which should call Herb::Visitor's implementation) vs
          # calls originating from Herb::Visitor (which should call the cop's implementation,
          # allowing overrides and super calls in the cop to work as expected).
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{method_name}(node, call_super: false)             # def visit_erb_node(node, call_super: false)
              call_super ? super(node) : @cop.#{method_name}(node)  #   call_super ? super(node) : @cop.visit_erb_node(node)
            end                                                     # end
          RUBY
        end
      end
      private_constant :Visitor
    end
  end
end

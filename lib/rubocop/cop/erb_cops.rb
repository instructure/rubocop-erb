# frozen_string_literal: true

require_relative 'mixin/herb_location_helper'
require_relative 'mixin/herb_visitor'
require_relative 'mixin/ignore_at_end_of_erb_node'
require_relative 'mixin/ignore_at_start_of_erb_node'
require_relative 'mixin/ignore_across_erb_nodes'
require_relative 'mixin/rendered_statement'

require_relative 'erb/block_alignment'
require_relative 'erb/empty_tag'
require_relative 'erb/erb_error'
require_relative 'erb/first_line_line_break'
require_relative 'erb/indentation'
require_relative 'erb/leading_empty_lines'
require_relative 'erb/leading_whitespace'
require_relative 'erb/multiline_tag_layout'
require_relative 'erb/output_safety'
require_relative 'erb/redundant_string_coercion'
require_relative 'erb/space_after_opening_tag'
require_relative 'erb/space_before_closing_tag'
require_relative 'erb/tag_alignment'
require_relative 'erb/tag_indentation'
require_relative 'erb/trailing_empty_lines'

require_relative 'erb/layout/comment_indentation'
require_relative 'erb/layout/empty_lines_around_block_body'
require_relative 'erb/layout/indentation_consistency'
require_relative 'erb/layout/indentation_width'
require_relative 'erb/layout/trailing_whitespace'
require_relative 'erb/lint/duplicate_branch'
require_relative 'erb/lint/empty_when'
require_relative 'erb/lint/syntax'
require_relative 'erb/lint/void'
require_relative 'erb/style/empty_else'
require_relative 'erb/style/identical_conditional_branches'
require_relative 'erb/style/if_inside_else'
require_relative 'erb/style/next'
require_relative 'erb/style/semicolon'
require_relative 'erb/style/sole_nested_conditional'

RuboCop::Cop::Layout::BlockAlignment.prepend(RuboCop::Cop::ERB::IgnoreAtStartOfERBNode)
RuboCop::Cop::Layout::CommentIndentation.prepend(RuboCop::Cop::ERB::Layout::CommentIndentation)
RuboCop::Cop::Layout::EmptyLinesAroundBlockBody.prepend(RuboCop::Cop::ERB::Layout::EmptyLinesAroundBlockBody)
RuboCop::Cop::Layout::ElseAlignment.prepend(RuboCop::Cop::ERB::IgnoreAtStartOfERBNode)
RuboCop::Cop::Layout::EndAlignment.prepend(RuboCop::Cop::ERB::IgnoreAtStartOfERBNode)
RuboCop::Cop::Layout::IndentationConsistency.prepend(RuboCop::Cop::ERB::Layout::IndentationConsistency)
RuboCop::Cop::Layout::IndentationWidth.prepend(RuboCop::Cop::ERB::IgnoreAtStartOfERBNode)
RuboCop::Cop::Layout::IndentationWidth.prepend(RuboCop::Cop::ERB::Layout::IndentationWidth)
RuboCop::Cop::Layout::ExtraSpacing.prepend(RuboCop::Cop::ERB::IgnoreAtEndOfERBNode)
RuboCop::Cop::Layout::ExtraSpacing.prepend(RuboCop::Cop::ERB::IgnoreAtStartOfERBNode)
RuboCop::Cop::Layout::SpaceBeforeSemicolon.prepend(RuboCop::Cop::ERB::IgnoreAtEndOfERBNode)
RuboCop::Cop::Layout::TrailingWhitespace.prepend(RuboCop::Cop::ERB::IgnoreAtEndOfERBNode)
RuboCop::Cop::Layout::TrailingWhitespace.prepend(RuboCop::Cop::ERB::Layout::TrailingWhitespace)
RuboCop::Cop::Lint::EmptyBlock.prepend(RuboCop::Cop::ERB::IgnoreAcrossERBNodes)
RuboCop::Cop::Lint::DuplicateBranch.prepend(RuboCop::Cop::ERB::Lint::DuplicateBranch)
RuboCop::Cop::Lint::EmptyConditionalBody.prepend(RuboCop::Cop::ERB::IgnoreAcrossERBNodes)
RuboCop::Cop::Lint::EmptyWhen.prepend(RuboCop::Cop::ERB::Lint::EmptyWhen)
RuboCop::Cop::Lint::Syntax.prepend(RuboCop::Cop::ERB::Lint::Syntax)
RuboCop::Cop::Lint::Void.prepend(RuboCop::Cop::ERB::Lint::Void)
RuboCop::Cop::Style::EmptyElse.prepend(RuboCop::Cop::ERB::Style::EmptyElse)
RuboCop::Cop::Style::IdenticalConditionalBranches.prepend(RuboCop::Cop::ERB::Style::IdenticalConditionalBranches)
RuboCop::Cop::Style::IfInsideElse.prepend(RuboCop::Cop::ERB::Style::IfInsideElse)
RuboCop::Cop::Style::IfWithSemicolon.prepend(RuboCop::Cop::ERB::IgnoreAcrossERBNodes)
RuboCop::Cop::Style::Next.prepend(RuboCop::Cop::ERB::Style::Next)
RuboCop::Cop::Style::RedundantCondition.prepend(RuboCop::Cop::ERB::IgnoreAcrossERBNodes)
RuboCop::Cop::Style::SafeNavigation.prepend(RuboCop::Cop::ERB::IgnoreAcrossERBNodes)
RuboCop::Cop::Style::Semicolon.prepend(RuboCop::Cop::ERB::Style::Semicolon)
RuboCop::Cop::Style::SoleNestedConditional.prepend(RuboCop::Cop::ERB::Style::SoleNestedConditional)
RuboCop::Cop::Style::SymbolProc.prepend(RuboCop::Cop::ERB::IgnoreAcrossERBNodes)

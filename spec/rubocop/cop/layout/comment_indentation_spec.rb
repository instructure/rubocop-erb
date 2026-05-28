# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::CommentIndentation, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for a comment at the start of an ERB tag' do
    expect_no_offenses(<<~ERB, filename)
      <%
      # comment
      %>
    ERB
  end

  it 'does not register an offense for a multi-line comment block followed only by the closing tag' do
    expect_no_offenses(<<~ERB, filename)
      <%
      # Copyright (C) 2024 Acme
      #
      # This file is part of something.
      %>
    ERB
  end

  it 'does not register an offense for an indented comment block followed only by the closing tag' do
    expect_no_offenses(<<~ERB, filename)
      <%
        # Copyright (C) 2024 Acme
        #
        # This file is part of something.
      %>
    ERB
  end

  it 'registers an offense for a misindented comment within a single ERB tag' do
    expect_offense(<<~ERB, filename)
      <%
        foo
          # bad
          ^^^^^ Incorrect indentation detected (column 4 instead of 2).
        bar
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        foo
        # bad
        bar
      %>
    ERB
  end
end

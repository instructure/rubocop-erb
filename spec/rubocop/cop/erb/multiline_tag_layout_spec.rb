# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::MultilineTagLayout, :config do
  let(:filename) { 'dummy.erb' }
  let(:supported) { %w[symmetrical new_line same_line] }

  context 'when the last content is a heredoc sentinel' do
    let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

    it 'moves the opening tag onto its own line instead of corrupting the heredoc' do
      expect_offense(<<~ERB, filename)
        <%= render(inline: <<~HTML)
        ^^^ The opening ERB tag must be on its own line when the last content is a heredoc, since the closing tag cannot share that line.
          <p>hi</p>
        HTML
        %>
      ERB

      expect_correction(<<~ERB)
        <%=
          render(inline: <<~HTML)
          <p>hi</p>
        HTML
        %>
      ERB
    end

    it 'does not register an offense when the opening tag is already on its own line' do
      expect_no_offenses(<<~ERB, filename)
        <%=
          render(inline: <<~HTML)
          <p>hi</p>
        HTML
        %>
      ERB
    end

    context 'with EnforcedStyle: same_line' do
      let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

      it 'does not register an offense (the closing tag cannot share the sentinel line)' do
        expect_no_offenses(<<~ERB, filename)
          <%= render(inline: <<~HTML)
            <p>hi</p>
          HTML
          %>
        ERB
      end
    end
  end

  context 'with EnforcedStyle: symmetrical' do
    let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

    it 'does not register an offense when opening and closing tags are symmetrical' do
      expect_no_offenses(<<~ERB, filename)
        <% foo(a,
               b) %>
      ERB
    end

    it 'does not register an offense for a single-line tag' do
      expect_no_offenses(<<~ERB, filename)
        <% foo(a, b) %>
      ERB
    end

    it 'moves the closing tag onto the last content line when the opening tag shares the first content line' do
      expect_offense(<<~ERB, filename)
        <% foo(a,
               b)
        %>
        ^^ The closing ERB tag must be on the same line as the last content when the opening tag is on the same line as the first content.
      ERB

      expect_correction(<<~ERB)
        <% foo(a,
               b) %>
      ERB
    end

    it 'moves the closing tag onto its own line when the opening tag is on its own line' do
      expect_offense(<<~ERB, filename)
        <%
          foo(a,
              b) %>
                 ^^ The closing ERB tag must be on the line after the last content when the opening tag is on a separate line from the first content.
      ERB

      expect_correction(<<~ERB)
        <%
          foo(a,
              b)
        %>
      ERB
    end
  end

  context 'with EnforcedStyle: new_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'new_line' } }

    it 'requires the closing tag on a new line' do
      expect_offense(<<~ERB, filename)
        <% foo(a,
               b) %>
                  ^^ The closing ERB tag must be on the line after the last content.
      ERB

      expect_correction(<<~ERB)
        <% foo(a,
               b)
        %>
      ERB
    end
  end

  context 'with EnforcedStyle: same_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

    it 'requires the closing tag on the last content line' do
      expect_offense(<<~ERB, filename)
        <% foo(a,
               b)
        %>
        ^^ The closing ERB tag must be on the same line as the last content.
      ERB

      expect_correction(<<~ERB)
        <% foo(a,
               b) %>
      ERB
    end
  end
end

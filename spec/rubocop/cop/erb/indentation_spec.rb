# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::Indentation, :config do
  let(:filename) { 'dummy.erb' }

  context 'when there is code on the opening tag line' do
    it 'registers an offense unless indented one past the opening tag' do
      expect_offense(<<~ERB, filename)
        <% foo
             bar %>
             ^^^^^^ Use 3 spaces for indentation of the first line in a multi-line ERB tag.
      ERB

      expect_correction(<<~ERB)
        <% foo
           bar %>
      ERB
    end

    it 'uses four spaces for an output tag' do
      expect_offense(<<~ERB, filename)
        <%= foo
              bar %>
              ^^^^^^ Use 4 spaces for indentation of the first line in a multi-line ERB tag.
      ERB

      expect_correction(<<~ERB)
        <%= foo
            bar %>
      ERB
    end

    it 'uses five spaces for a raw output tag' do
      expect_offense(<<~ERB, filename)
        <%== foo
               bar %>
               ^^^^^^ Use 5 spaces for indentation of the first line in a multi-line ERB tag.
      ERB

      expect_correction(<<~ERB)
        <%== foo
             bar %>
      ERB
    end

    it 'does not register an offense when already indented one past the opening tag' do
      expect_no_offenses(<<~ERB, filename)
        <% foo
           bar %>
      ERB
    end
  end

  context 'when the line continues a multi-line expression from the opening line' do
    it 'does not flag continued method arguments (Layout/ArgumentAlignment handles it)' do
      expect_no_offenses(<<~ERB, filename)
        <%= t "a message",
              key: value,
              other: thing %>
      ERB
    end

    it 'does not flag continued array elements' do
      expect_no_offenses(<<~ERB, filename)
        <%= [first,
               second] %>
      ERB
    end

    it 'does not flag continued hash elements' do
      expect_no_offenses(<<~ERB, filename)
        <%= { a: 1,
                b: 2 } %>
      ERB
    end

    it 'does not flag a heredoc body' do
      expect_no_offenses(<<~ERB, filename)
        <%= render(inline: <<~HTML
          <p>hi</p>
          HTML
        ) %>
      ERB
    end

    it 'still flags a genuinely new statement on the next line' do
      expect_offense(<<~ERB, filename)
        <% foo
             bar %>
             ^^^^^^ Use 3 spaces for indentation of the first line in a multi-line ERB tag.
      ERB

      expect_correction(<<~ERB)
        <% foo
           bar %>
      ERB
    end
  end

  context 'when the opening tag is on its own line' do
    it 'registers an offense unless indented by the configured width' do
      expect_offense(<<~ERB, filename)
        <%
            foo
            ^^^ Use 2 spaces for indentation of the first line in a multi-line ERB tag.
          bar
        %>
      ERB

      expect_correction(<<~ERB)
        <%
          foo
          bar
        %>
      ERB
    end

    it 'does not register an offense when indented by the configured width' do
      expect_no_offenses(<<~ERB, filename)
        <%
          foo
          bar
        %>
      ERB
    end
  end

  context 'when the tag is an ERB comment tag' do
    it 'registers an offense unless the content aligns with the hash' do
      expect_offense(<<~ERB, filename)
        <%#
            comment
            ^^^^^^^ Use 2 spaces for indentation of the first line in a multi-line ERB tag.
        %>
      ERB

      expect_correction(<<~ERB)
        <%#
          comment
        %>
      ERB
    end

    it 'aligns content on the opening line with the hash too' do
      expect_offense(<<~ERB, filename)
        <%# foo
              bar %>
              ^^^^^^ Use 2 spaces for indentation of the first line in a multi-line ERB tag.
      ERB

      expect_correction(<<~ERB)
        <%# foo
          bar %>
      ERB
    end

    it 'does not register an offense when the content aligns with the hash' do
      expect_no_offenses(<<~ERB, filename)
        <%#
          comment
        %>
      ERB
    end
  end

  it 'does not register an offense for a single-line tag' do
    expect_no_offenses(<<~ERB, filename)
      <% foo %>
    ERB
  end

  context 'with AllowZeroIndentForInitialBlockComment' do
    context 'when true' do
      let(:cop_config) { { 'AllowZeroIndentForInitialBlockComment' => true } }

      it 'allows an initial comment block flush against column 0' do
        expect_no_offenses(<<~ERB, filename)
          <%
          # Copyright (C) 2024 Acme
          #
          # This file is part of something.
          %>
        ERB
      end

      it 'allows an initial Ruby block comment flush against column 0' do
        expect_no_offenses(<<~ERB, filename)
          <%
          =begin
          license text
          =end
          %>
        ERB
      end

      it 'still registers an offense when there is code on the opening line' do
        expect_offense(<<~ERB, filename)
          <% foo
          # comment
          ^^^^^^^^^ Use 3 spaces for indentation of the first line in a multi-line ERB tag.
          %>
        ERB
      end

      it 'still registers an offense when the tag is not at the top of the file' do
        expect_offense(<<~ERB, filename)
          <div></div>
          <%
          # comment
          ^^^^^^^^^ Use 2 spaces for indentation of the first line in a multi-line ERB tag.
          %>
        ERB
      end

      it 'registers an offense for an output tag' do
        expect_offense(<<~ERB, filename)
          <%=
          # comment
          ^^^^^^^^^ Use 2 spaces for indentation of the first line in a multi-line ERB tag.
          %>
        ERB
      end

      it 'registers an offense when there are non-comment lines in the tag' do
        expect_offense(<<~ERB, filename)
          <%
          # Copyright (C) 2024 Acme
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Use 2 spaces for indentation of the first line in a multi-line ERB tag.
          foo
          %>
        ERB
      end
    end

    context 'when false' do
      let(:cop_config) { { 'AllowZeroIndentForInitialBlockComment' => false } }

      it 'registers an offense for an initial comment block flush against column 0' do
        expect_offense(<<~ERB, filename)
          <%
          # Copyright (C) 2024 Acme
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Use 2 spaces for indentation of the first line in a multi-line ERB tag.
          %>
        ERB
      end
    end
  end
end

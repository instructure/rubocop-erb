# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::IndentationWidth, :config do
  let(:filename) { 'dummy.erb' }

  it 'does not register an offense for random ERB tags' do
    expect_no_offenses(<<~ERB, filename)
      <% things.each do |thing| %>
        <span>
          <%= other_thing.name %>
        </span>
      <% end %>
    ERB
  end

  it 'autocorrects a nested offense even when the outer offense is suppressed at the ERB tag start' do
    # The `case` sits at the start of the ERB tag (suppressed), but its `when`
    # bodies are nested within it -- they must still autocorrect rather than be
    # perpetually deferred behind the suppressed outer offense.
    expect_offense(<<~ERB, filename)
      <p><em><%=
                case criterion
                when 'a'
        t('x')
        ^^^^^^ Use 2 (not -8) spaces for indentation.
                end
              %></em></p>
    ERB

    expect_correction(<<~ERB)
      <p><em><%=
                case criterion
                when 'a'
                  t('x')
                end
              %></em></p>
    ERB
  end

  it 'registers an offense in plain ruby' do
    expect_offense(<<~ERB, filename)
      <%
        things.each do |thing|
            puts other_thing.name
        ^^^^ Use 2 (not 4) spaces for indentation.
        end
      %>
    ERB

    expect_correction(<<~ERB)
      <%
        things.each do |thing|
          puts other_thing.name
        end
      %>
    ERB
  end
end

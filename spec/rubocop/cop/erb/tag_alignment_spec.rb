# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::TagAlignment, :config do
  let(:filename) { 'dummy.erb' }

  it 'registers an offense for a closing tag more deeply aligned than its opening tag' do
    expect_offense(<<~ERB, filename)
      <%
        do_something
       %>
       ^^ Align ERB closing tags with their opening tag.
    ERB

    expect_correction(<<~ERB)
      <%
        do_something
      %>
    ERB
  end

  it 'registers an offense for a closing tag less deeply aligned than its opening tag' do
    expect_offense(<<~ERB, filename)
      <html>
        <%
          do_something
       %>
       ^^ Align ERB closing tags with their opening tag.
      </html>
    ERB

    expect_correction(<<~ERB)
      <html>
        <%
          do_something
        %>
      </html>
    ERB
  end

  it 'does not register an offense for an aligned closing tag' do
    expect_no_offenses(<<~ERB, filename)
      <%
        do_something
      %>
    ERB
  end

  it 'does not register an offense for a single line tag' do
    expect_no_offenses(<<~ERB, filename)
      <% do_something %>
    ERB
  end
end

# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ERB::RedundantStringCoercion, :config do
  let(:filename) { 'dummy.html.erb' }

  it 'registers an offense and removes a redundant to_s in an output tag' do
    expect_offense(<<~ERB, filename)
      <%= user.name.to_s %>
                    ^^^^ Redundant use of `Object#to_s` on the value rendered by an ERB output tag.
    ERB

    expect_correction(<<~ERB)
      <%= user.name %>
    ERB
  end

  it 'registers an offense for a raw output tag' do
    expect_offense(<<~ERB, filename)
      <%== value.to_s %>
                 ^^^^ Redundant use of `Object#to_s` on the value rendered by an ERB output tag.
    ERB

    expect_correction(<<~ERB)
      <%== value %>
    ERB
  end

  it 'only flags the final statement of a multi-statement tag' do
    expect_offense(<<~ERB, filename)
      <%= foo.to_s; bar.to_s %>
                        ^^^^ Redundant use of `Object#to_s` on the value rendered by an ERB output tag.
    ERB

    expect_correction(<<~ERB)
      <%= foo.to_s; bar %>
    ERB
  end

  it 'does not register an offense for a non-output tag' do
    expect_no_offenses(<<~ERB, filename)
      <% value.to_s %>
    ERB
  end

  it 'does not register an offense when to_s takes arguments' do
    expect_no_offenses(<<~ERB, filename)
      <%= count.to_s(2) %>
    ERB
  end

  it 'does not register an offense for to_s nested inside the rendered statement' do
    expect_no_offenses(<<~ERB, filename)
      <%= cond ? a.to_s : b %>
    ERB
  end

  it 'does not register an offense when no to_s is present' do
    expect_no_offenses(<<~ERB, filename)
      <%= user.name %>
    ERB
  end

  it 'removes a safe-navigation to_s' do
    expect_offense(<<~ERB, filename)
      <%= user&.name&.to_s %>
                      ^^^^ Redundant use of `Object#to_s` on the value rendered by an ERB output tag.
    ERB

    expect_correction(<<~ERB)
      <%= user&.name %>
    ERB
  end
end

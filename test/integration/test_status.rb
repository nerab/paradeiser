require 'helper'

class TestStatusCommand < Paradeiser::IntegrationTest
  def test_status
    assert_command('status', 255) # not initialized
    out = assert_command('start')
    refute_empty(out, "Expected 'start' to produce an non-empty output")

    assert_command('status')
  end
end

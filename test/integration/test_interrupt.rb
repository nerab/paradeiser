require 'helper'

class TestInterruptCommand < Paradeiser::IntegrationTest
  def test_interrupt
    refute_command('interrupt')
    assert_command('start')
    assert_command('interrupt')
  end
end

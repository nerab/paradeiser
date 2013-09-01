require 'helper'

module ParadeiserTest
  class TestInterruptCommand < IntegrationTest
    def test_interrupt
      refute_command('interrupt')
      assert_command('start')
      assert_command('interrupt')
    end
  end
end

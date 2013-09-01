require 'helper'

module ParadeiserTest
  class TestStatusCommand < IntegrationTest
    def test_status
      assert_command('status', 255) # not initialized
      assert_command('start')
      out = assert_command('status')
      refute_empty(out, "Expected 'status' to produce an non-empty output")
    end
  end
end

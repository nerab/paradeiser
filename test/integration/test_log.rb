require 'helper'

module ParadeiserTest
  class TestLogCommand < IntegrationTest
    def test_log_inactive
      assert_command('log', 0, name.split('_'))
    end

    def test_log_active
      assert_command('start')
      assert_command('log', 0, name.split('_'))
    end
  end
end

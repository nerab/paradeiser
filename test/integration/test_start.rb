require 'helper'

module ParadeiserTest
  class TestStartCommand < IntegrationTest
    def test_start
      assert_command('start')
    end
  end
end

require 'helper'

module ParadeiserTest
  class TestFinishCommand < IntegrationTest
    def test_finish
      refute_command('finish')
      assert_command('start')
      assert_command('finish')
    end
  end
end

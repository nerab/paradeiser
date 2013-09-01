require 'helper'

module ParadeiserTest
  class TestNoArgsCommand < IntegrationTest
    def test_no_args
      assert_command('')
    end
  end
end

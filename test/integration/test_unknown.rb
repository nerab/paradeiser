require 'helper'

module ParadeiserTest
  class TestUnknownCommand < IntegrationTest
    def test_unknown
      refute_command('unknown')
    end
  end
end

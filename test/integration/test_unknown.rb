require 'helper'

class TestUnknownCommand < Paradeiser::IntegrationTest
  def test_unknown
    refute_command('unknown')
  end
end

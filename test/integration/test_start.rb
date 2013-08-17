require 'helper'

class TestStartCommand < Paradeiser::IntegrationTest
  def test_start
    assert_command('start')
  end
end

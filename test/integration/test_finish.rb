require 'helper'

class TestFinishCommand < Paradeiser::IntegrationTest
  def test_finish
    refute_command('finish')
    assert_command('start')
    assert_command('finish')
  end
end

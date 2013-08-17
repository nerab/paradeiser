require 'helper'

class TestNoArgsCommand < Paradeiser::IntegrationTest
  def test_no_args
    assert_command('')
  end
end

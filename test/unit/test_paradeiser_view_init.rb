require 'helper'

class TestParadeiserViewInit < ParadeiserViewTest
  def test_init
    assert_match(/^Suffessfully initialized .+\.$/, render(:init))
  end
end

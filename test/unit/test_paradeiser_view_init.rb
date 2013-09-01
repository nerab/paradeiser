require 'helper'

module ParadeiserTest
  class TestParadeiserViewInit < ParadeiserViewTest
    def test_init
      assert_match(/^Successfully initialized .+\.$/, render(:init))
    end
  end
end

require 'helper'

class TestParadeiserViewStatus < ParadeiserViewTest
  def setup
    @pom = produce(Pomodoro)
    @pom.id = 1
  end

  def test_active
    assert_match(/^Pomodoro #1 is active for another .* minutes \(started at .*\)\.$/m, render(:status))
  end

  def test_finished
    finish!
    assert_match(/^Nothing active. Last pomodoro was finished at .*\.$/m, render(:status))
  end
end

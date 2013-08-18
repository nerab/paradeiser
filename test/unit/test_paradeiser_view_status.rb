require 'helper'

class TestParadeiserViewStatus < ParadeiserViewTest
  def setup
    @pom = Pomodoro.new
    @pom.id = 1
  end

  def test_idle
    assert_match(/^Current state is idle.$/m, render(:status))
  end

  def test_active
    start!
    assert_match(/^Pomodoro #1 is active for another \d{1,2} minutes \(started at .*\)\.$/m, render(:status))
  end

  def test_finished
    start!
    finish!
    assert_match(/^Nothing active. Last pomodoro was finished at .*\.$/m, render(:status))
  end
end

require 'helper'

class TestViewStatus < MiniTest::Test
  def setup
    @pom = Pomodoro.new
    @pom.id = 1
  end

  def test_status_idle
    out, err = render(:status)
    assert_match(/^Current state is idle.$/m, out)
    assert_empty(err)
  end

  def test_status_active
    start!
    out, err = render(:status)
    assert_match(/^Pomodoro #1 is active for another \d{1,2} minutes \(started at .*\)\.$/m, out)
    assert_empty(err)
  end

  def test_status_finished
    start!
    finish!
    out, err = render(:status)
    assert_match(/^Nothing active. Last pomodoro was finished at .*\.$/m, out)
    assert_empty(err)
  end

private

  def render(method)
    capture_io do
      View.new('Paradeiser', method).render(binding)
    end
  end
end

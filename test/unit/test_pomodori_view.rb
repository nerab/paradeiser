require 'helper'

class TestPomodoriView < ViewTest
  def setup
    @pom = Pomodoro.new
    @pom.id = 1
  end

  def test_start
    assert_match(/^Starting pomodoro #1\.$/m, render(:start))
  end

  def test_finish
    start!
    assert_match(/^Finished pomodoro #1 after .* minutes\.$/m, render(:finish))
  end

  def test_cancel
    start!
    cancel!
    assert_match(/^Canceled pomodoro #1 after .* minutes\.$/m, render(:cancel))
  end

protected

  def model
    'Pomodoro'
  end
end

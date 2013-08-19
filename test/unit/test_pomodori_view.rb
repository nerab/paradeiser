require 'helper'

class TestPomodoriView < ViewTest
  def setup
    @pom = produce(Pomodoro)
    @pom.id = 1
  end

  def test_start
    assert_match(/^Started pomodoro #1\.$/m, render(:start))
  end

  def test_finish
    assert_match(/^Finished pomodoro #1 after .* minutes\.$/m, render(:finish))
  end

  def test_cancel
    cancel!
    assert_match(/^Canceled pomodoro #1 after .* minutes\.$/m, render(:cancel))
  end

  def test_interrupt_internal
    @interrupt_type = 'internally'
    assert_match(/^Marked pomodoro #1 as internally interrupted\.$/m, render(:interrupt))
  end

  def test_interrupt_external
    @interrupt_type = 'externally'
    assert_match(/^Marked pomodoro #1 as externally interrupted\.$/m, render(:interrupt))
  end

protected

  def model
    'Pomodoro'
  end
end

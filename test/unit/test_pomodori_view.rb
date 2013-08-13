require 'helper'

class TestPomodoriView < MiniTest::Test
  def setup
    @pom = Pomodoro.new
    @pom.id = 1
  end

  def test_start
    out, err = render(:start)
    assert_match(/^Starting pomodoro #1\.$/m, out)
    assert_empty(err)
  end

  def test_finish
    start!
    out, err = render(:finish)
    assert_match(/^Finished pomodoro #1 after .* minutes\.$/m, out)
  end

private

  def render(method)
    capture_io do
      View.new('Pomodori', method).render(binding)
    end
  end
end

require 'helper'

class TestPomodoriView < MiniTest::Test
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
    @pom.finish!
    out, err = render(:status)
    assert_match(/^No active pomodoro. Last one was finished at .*\.$/m, out)
    assert_empty(err)
  end

  def test_report_empty
    @pom = []
    out, err = render(:report)
    assert_equal(1, out.lines.size)
    assert_match(/^ID \| Status \| Started \| Ended$/m, out.lines.first)
    assert_empty(err)
  end

  def test_report_one_active
    start!
    @pom = [@pom]
    out, err = render(:report)
    assert_equal(2, out.lines.size)
    assert_match(/^ID \| Status \| Started \| Ended$/m, out.lines[0])
    assert_match(/^1 \| active \| \d{1,2}:\d{1,2} \| $/m, out.lines[1])
    assert_empty(err)
  end

  def test_report_one_finished
    start!
    @pom.finish!
    @pom = [@pom]
    out, err = render(:report)
    assert_equal(2, out.lines.size)
    assert_match(/^ID \| Status \| Started \| Ended$/m, out.lines[0])
    assert_match(/^1 \| finished \| \d{1,2}:\d{1,2} \| \d{1,2}:\d{1,2}$/m, out.lines[1])
    assert_empty(err)
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

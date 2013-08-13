require 'helper'

class TestParadeiserControllerReport < ControllerTest
  def setup
    @backend = PStoreMock.new
  end

  def test_idle
    br3ak, has_output = invoke(:report, '@pom', 'has_output')
    assert_empty(br3ak)
    assert_equal(true, has_output)
  end

  def test_active_break
    @backend[:foo] = SchedulableMock.new(:status_name => :active)

    br3ak, has_output = invoke(:report, '@pom', 'has_output')
    assert_equal(1, br3ak.size)
    assert_equal(true, has_output)
  end

  def test_finished_break
    @backend[:foo] = SchedulableMock.new(:status_name => :finished)
    @backend[:bar] = SchedulableMock.new(:status_name => :active)
    br3ak, has_output = invoke(:report, '@pom', 'has_output')
    assert_equal(2, br3ak.size)
    assert_equal(true, has_output)
  end

  def test_active_pom
    @backend[:bar] = SchedulableMock.new(:status_name => :active)
    pomodori, has_output = invoke(:report, '@pom', 'has_output')
    assert_equal(1, pomodori.size)
    assert_equal(true, has_output)
  end

  def test_finished_pom
    @backend[:foo] = SchedulableMock.new(:status_name => :finished)
    @backend[:bar] = SchedulableMock.new(:status_name => :active)
    pomodori, has_output = invoke(:report, '@pom', 'has_output')
    assert_equal(2, pomodori.size)
    assert_equal(true, has_output)
  end
end

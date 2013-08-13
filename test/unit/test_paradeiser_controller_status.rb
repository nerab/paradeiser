require 'helper'

class TestParadeiserControllerStatus < ControllerTest
  def setup
    @backend = PStoreMock.new
  end

  def test_status_idle
    exitstatus, has_output = invoke(:status, 'exitstatus', 'has_output')
    assert_equal(-1, exitstatus)
    assert_equal(true, has_output)
    assert_equal(0, @backend.size)
  end

  def test_status_active_pom
    @backend[:foo] = SchedulableMock.new(
      :status => 'active',
      :status_name => :active,
      :active => true,
      :name => 'pomodoro')

    pom, has_output, exitstatus = invoke(:status, '@pom', 'has_output', 'exitstatus')
    assert_equal(0, exitstatus)
    assert_equal(:active, pom.status_name)
    assert_equal(true, has_output)
    assert_equal(1, @backend.size)
  end

  def test_status_finished_pom
    @backend[:foo] = SchedulableMock.new(
      :status => 'finished',
      :status_name => :finished,
      :finished => true,
      :name => 'pomodoro')

    pom, has_output, exitstatus = invoke(:status, '@pom', 'has_output', 'exitstatus')
    assert_equal(1, exitstatus)
    assert_equal(:finished, pom.status_name)
    assert_equal(true, has_output)
    assert_equal(1, @backend.size)
  end

  def test_status_active_break
    @backend[:foo] = SchedulableMock.new(
      :status => 'active',
      :status_name => :active,
      :active => true,
      :name => 'break')

    pom, has_output, exitstatus = invoke(:status, '@pom', 'has_output', 'exitstatus')
    assert_equal(2, exitstatus)
    assert_equal(:active, pom.status_name)
    assert_equal(true, has_output)
    assert_equal(1, @backend.size)
  end

  def test_status_finished_break
    @backend[:foo] = SchedulableMock.new(
      :status => 'finished',
      :status_name => :finished,
      :finished => true,
      :name => 'break')

    pom, has_output, exitstatus = invoke(:status, '@pom', 'has_output', 'exitstatus')
    assert_equal(3, exitstatus)
    assert_equal(:finished, pom.status_name)
    assert_equal(true, has_output)
    assert_equal(1, @backend.size)
  end
end

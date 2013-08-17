require 'helper'

class TestParadeiserControllerStatus < ParadeiserControllerTest
  def setup
    @backend = PStoreMock.new
  end

  def test_status_idle
    attrs = invoke(:status, 'exitstatus', 'has_output')
    assert_equal(-1, attrs[:exitstatus])
    assert_equal(true, attrs[:has_output])
    assert_equal(0, @backend.size)
  end

  def test_status_active_pom
    @backend[:foo] = SchedulableMock.new(
      :status => 'active',
      :status_name => :active,
      :active => true,
      :name => 'pomodoro')

    attrs = invoke(:status, '@pom', 'has_output', 'exitstatus')
    assert_equal(0, attrs[:exitstatus])
    assert_equal(:active, attrs[:pom].status_name)
    assert_equal(true, attrs[:has_output])
    assert_equal(1, @backend.size)
  end

  def test_status_finished_pom
    @backend[:foo] = SchedulableMock.new(
      :status => 'finished',
      :status_name => :finished,
      :finished => true,
      :name => 'pomodoro')

    attrs = invoke(:status, '@pom', 'has_output', 'exitstatus')
    assert_equal(1, attrs[:exitstatus])
    assert_equal(:finished, attrs[:pom].status_name)
    assert_equal(true, attrs[:has_output])
    assert_equal(1, @backend.size)
  end

  def test_status_active_break
    @backend[:foo] = SchedulableMock.new(
      :status => 'active',
      :status_name => :active,
      :active => true,
      :name => 'break')

    attrs = invoke(:status, '@pom', 'has_output', 'exitstatus')
    assert_equal(2, attrs[:exitstatus])
    assert_equal(:active, attrs[:pom].status_name)
    assert_equal(true, attrs[:has_output])
    assert_equal(1, @backend.size)
  end

  def test_status_finished_break
    @backend[:foo] = SchedulableMock.new(
      :status => 'finished',
      :status_name => :finished,
      :finished => true,
      :name => 'break')

    attrs = invoke(:status, '@pom', 'has_output', 'exitstatus')
    assert_equal(3, attrs[:exitstatus])
    assert_equal(:finished, attrs[:pom].status_name)
    assert_equal(true, attrs[:has_output])
    assert_equal(1, @backend.size)
  end
end

require 'helper'

class TestPomodoro < MiniTest::Test
  def setup
    @pom = Pomodoro.new
  end

  def test_virgin
    assert_equal(:idle, @pom.status_name)
    refute(@pom.started_at)
    refute(@pom.canceled_at)
    refute(@pom.finished_at)
  end

  def test_finish_idle
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
    refute(@pom.started_at)
    refute(@pom.canceled_at)
    refute(@pom.finished_at)
  end

  def test_finish_active
    start!
    assert_equal(:active, @pom.status_name)

    now = srand

    Time.stub :now, Time.at(now) do
      finish!
    end

    assert_equal(:finished, @pom.status_name)
    assert_equal(now, @pom.finished_at.to_i)
    refute(@pom.canceled_at)
  end

  def test_finish_finished
    start!
    finish!
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
    refute(@pom.canceled_at)
  end

  def test_finish_canceled
    start!
    cancel!
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
    refute(@pom.finished_at)
  end

  def test_length
    assert_equal(25 * 60, @pom.length)
  end

  def test_duration_idle
    assert_equal(0, @pom.duration)
  end

  def test_duration_started
    now = srand

    Time.stub :now, Time.at(now) do
      start!
    end

    later = now + rand(42)

    Time.stub :now, Time.at(later) do
      assert_equal(later - now, @pom.duration)
    end
  end

  def test_duration_finished
    now = srand

    Time.stub :now, Time.at(now) do
      start!
    end

    later = now + rand(42)

    Time.stub :now, Time.at(later) do
      finish!
    end

    assert_equal(later - now, @pom.duration)
  end

  def test_duration_canceled
    now = srand

    Time.stub :now, Time.at(now) do
      start!
    end

    later = now + rand(42)

    Time.stub :now, Time.at(later) do
      cancel!
    end

    assert_equal(later - now, @pom.duration)
  end

  def test_start
    now = srand

    Time.stub :now, Time.at(now) do
      start!
    end

    assert_equal(:active, @pom.status_name)
    assert_equal(now, @pom.started_at.to_i)
  end

  def test_remaining_active
    now = srand

    Time.stub :now, Time.at(now) do
      start!
      assert_equal(Pomodoro::MINUTES_25 * 60, @pom.remaining)
    end

    delta = 600
    later = now + delta

    Time.stub :now, Time.at(later) do
      assert_equal(Pomodoro::MINUTES_25 * 60 - delta, @pom.remaining)
    end
  end

  def test_interrupt
    start!
    assert_equal(0, @pom.interrupts.size)

    now = srand

    Time.stub :now, Time.at(now) do
      @pom.interrupt
    end

    assert_equal(1, @pom.interrupts.size)

    int = @pom.interrupts.first
    assert_equal(now, int.created_at.to_i)
    assert_equal(:internal, int.type)
  end

  def test_interrupt_internal
    start!
    @pom.interrupt(:internal)
    assert_equal(1, @pom.interrupts.size)
    int = @pom.interrupts.first
    assert_equal(:internal, int.type)
  end

  def test_interrupt_external
    start!
    @pom.interrupt(:external)
    assert_equal(1, @pom.interrupts.size)
    int = @pom.interrupts.first
    assert_equal(:external, int.type)
  end

  def test_interrupt_unknown
    start!
    assert_raises InvalidTypeError do
      @pom.interrupt(:unknown)
    end
  end

  def test_interrupt_idle
    assert_raises NotActiveError do
      @pom.interrupt
    end
  end

  def test_interrupt_finished
    start!
    finish!
    assert_raises NotActiveError do
      @pom.interrupt
    end
  end

  def test_interrupt_canceled
    start!
    cancel!
    assert_raises NotActiveError do
      @pom.interrupt
    end
  end

  def test_cancel_idle
    assert_raises StateMachine::InvalidTransition do
      cancel!
    end
    refute(@pom.finished_at)
    refute(@pom.canceled_at)
  end

  def test_cancel_active
    start!
    assert_equal(:active, @pom.status_name)

    now = srand

    Time.stub :now, Time.at(now) do
      cancel!
    end

    assert_equal(:canceled, @pom.status_name)
    assert_equal(now, @pom.canceled_at.to_i)
    refute(@pom.finished_at)
  end
end

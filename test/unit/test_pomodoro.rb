require 'helper'

class TestPomodoro < MiniTest::Test
  def setup
    @pom = produce(Pomodoro)
  end

  def test_finish_active
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
    finish!
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
    refute(@pom.canceled_at)
  end

  def test_finish_canceled
    cancel!
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
    refute(@pom.finished_at)
  end

  def test_length
    assert_equal(25 * 60, @pom.length)
  end

  def test_duration_started
    later = @started + rand(42)

    Time.stub :now, Time.at(later) do
      assert_equal(later - @started, @pom.duration)
    end
  end

  def test_duration_finished
    later = @started + rand(42)

    Time.stub :now, Time.at(later) do
      finish!
    end

    assert_equal(later - @started, @pom.duration)
  end

  def test_duration_canceled
    later = @started + rand(42)

    Time.stub :now, Time.at(later) do
      cancel!
    end

    assert_equal(later - @started, @pom.duration)
  end

  def test_start
    assert_equal(:active, @pom.status_name)
    assert_equal(@started, @pom.started_at.to_i)
  end

  def test_remaining_active
    Time.stub :now, Time.at(@started) do
      assert_equal(Pomodoro::MINUTES_25 * 60, @pom.remaining)
    end

    delta = 600
    later = @started + delta

    Time.stub :now, Time.at(later) do
      assert_equal(Pomodoro::MINUTES_25 * 60 - delta, @pom.remaining)
    end
  end

  def test_interrupt
    assert_equal(0, @pom.interrupts.size)

    now = srand

    Time.stub :now, Time.at(now) do
      interrupt!
    end

    assert_equal(1, @pom.interrupts.size)

    int = @pom.interrupts.first
    assert_equal(now, int.created_at.to_i)
    assert_equal(:internal, int.type)
  end

  def test_interrupt_internal
    interrupt!(:internal)
    assert_equal(1, @pom.interrupts.size)
    int = @pom.interrupts.first
    assert_equal(:internal, int.type)
  end

  def test_interrupt_external
    interrupt!(:external)
    assert_equal(1, @pom.interrupts.size)
    int = @pom.interrupts.first
    assert_equal(:external, int.type)
  end

  def test_interrupt_unknown
    assert_raises InvalidTypeError do
      interrupt!(:unknown)
    end
  end

  def test_interrupt_finished
    finish!
    assert_raises StateMachine::InvalidTransition do
      interrupt!
    end
  end

  def test_interrupt_canceled
    cancel!
    assert_raises StateMachine::InvalidTransition do
      interrupt!
    end
  end

  def test_cancel_active
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

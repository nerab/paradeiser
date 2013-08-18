require 'helper'

class TestBreak < MiniTest::Test
  def setup
    @break = produce(Break)
  end

  def test_new
    assert_equal(:active, @break.status_name)
  end

  def test_finish_break
    assert_equal(:active, @break.status_name)

    now = srand

    Time.stub :now, Time.at(now) do
      finish!
    end

    assert_equal(:finished, @break.status_name)
    assert_equal(now, @break.finished_at.to_i)
  end

  def test_length
    assert_equal(5 * 60, @break.length)
  end

  def test_duration
    later = @started + rand(42)

    Time.stub :now, Time.at(later) do
      assert_equal(later - @started, @break.duration)
    end
  end

  def test_duration_finished
    later = @started + rand(42)

    Time.stub :now, Time.at(later) do
      finish!
    end

    assert_equal(later - @started, @break.duration)
  end

  def test_finish_break
    finish!
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
  end

  def test_remaining
    delta = 120
    later = @started + delta

    Time.stub :now, Time.at(later) do
      assert_equal(@break.length - delta, @break.remaining)
    end
  end
end

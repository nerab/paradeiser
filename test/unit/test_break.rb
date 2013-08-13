require 'helper'

class TestBreak < MiniTest::Test
  def setup
    @break = Break.new
  end

  def test_virgin
    assert_equal(:idle, @break.status_name)
  end

  def test_break
    start!
    assert_equal(:active, @break.status_name)
  end

  def test_finish_idle
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
  end

  def test_finish_break
    start!
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


  def test_duration_idle
    assert_equal(0, @break.duration)
  end

  def test_duration
    now = srand

    Time.stub :now, Time.at(now) do
      start!
    end

    later = now + rand(42)

    Time.stub :now, Time.at(later) do
      assert_equal(later - now, @break.duration)
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

    assert_equal(later - now, @break.duration)
  end

  def test_finish_break
    start!
    finish!
    assert_raises StateMachine::InvalidTransition do
      finish!
    end
  end

  def test_remaining
    now = srand

    Time.stub :now, Time.at(now) do
      start!
      assert_equal(@break.length, @break.remaining)
    end

    delta = 120
    later = now + delta

    Time.stub :now, Time.at(later) do
      assert_equal(@break.length - delta, @break.remaining)
    end
  end
end

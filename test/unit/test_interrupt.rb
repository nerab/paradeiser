require 'helper'

class TestInterrupt < MiniTest::Test
  def setup
    @now = srand
  end

  def test_created_at
    int = new_interrupt
    assert_equal(@now, int.created_at.to_i)
  end

  def test_defaults_to_internal
    int = new_interrupt
    assert_equal(:internal, int.type)
  end

  def test_external
    int = new_interrupt(:external)
    assert_equal(:external, int.type)
  end

  def test_unknown
    assert_raises InvalidTypeError do
      new_interrupt(:unknown)
    end
  end

private

  def new_interrupt(type = nil)
    Time.stub :now, Time.at(@now) do
      Paradeiser::Interrupt.new(type)
    end
  end
end

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

private

  def new_interrupt(*args)
    Time.stub :now, Time.at(@now) do
      Paradeiser::Interrupt.new(*args)
    end
  end
end

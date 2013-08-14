require 'helper'

class TestPomodoriController < MiniTest::Test
  def setup
    @backend = PStoreMock.new
  end

  def test_start
    pom, has_output = invoke(:start, '@pom', 'has_output')
    assert_equal(:active, pom.status_name)
    assert_equal(false, has_output)
    assert_equal(1, @backend.size)
  end

  def test_start_active
    invoke(:start)
    assert_equal(1, @backend.size)

    assert_raises SingletonError do
      invoke(:start)
    end
    assert_equal(1, @backend.size)
  end

  def test_finish
    invoke(:start)
    pom, has_output = invoke(:finish, '@pom', 'has_output')
    assert_equal(:finished, pom.status_name)
    assert_equal(false, has_output)
    assert_equal(1, @backend.size)
  end

  def test_finish_idle
    assert_raises NotActiveError do
      invoke(:finish)
    end
    assert_equal(0, @backend.size)
  end

  def test_interrupt_active
    invoke(:start)
    pom, has_output = invoke(:interrupt, '@pom', 'has_output')
    assert_equal(:active, pom.status_name)

    interrupts = pom.interrupts
    refute_nil(interrupts)
    refute_empty(interrupts)
    assert_equal(1, interrupts.size)

    interrupt = interrupts.first
    refute_nil(interrupt)
    refute_nil(interrupt.created_at)
  end

private

  def invoke(method, *attributes)
    controller = PomodoriController.new(method)

    Repository.stub :backend, @backend do
      Scheduler.stub(:add, nil) do
        Scheduler.stub(:clear, nil) do
          controller.call(nil, nil)
        end
      end
    end

    attributes.map do |attribute|
      controller.get_binding.eval(attribute)
    end
  end
end

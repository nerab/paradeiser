require 'helper'

class TestInterruptsController < MiniTest::Test
  def setup
    @backend = PStoreMock.new
  end

  def test_interrupt_active
    invoke_pom(:start)
    pom, has_output = invoke(:create, '@pom', 'has_output')
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
    controller = InterruptsController.new(method)

    Repository.stub :backend, @backend do
      controller.call(nil, nil)
    end

    attributes.map do |attribute|
      controller.get_binding.eval(attribute)
    end
  end

  def invoke_pom(method, *attributes)
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

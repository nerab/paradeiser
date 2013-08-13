require 'minitest/autorun'
require 'paradeiser'
require_rel 'lib'

require 'lib/at_mock'

include Paradeiser

class MiniTest::Test

protected

  def start!(thing = @pom || @break)
    Scheduler.stub(:add, nil) do
      thing.start!
    end
  end

  def finish!(thing = @pom || @break)
    Scheduler.stub(:clear, nil) do
      thing.finish!
    end
  end
end


class ControllerTest < MiniTest::Test

protected

  def invoke(method, *attributes)
    controller = ParadeiserController.new(method)

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

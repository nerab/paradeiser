require 'minitest/autorun'
require 'paradeiser'
require_rel 'lib'

require 'lib/at_mock'

include Paradeiser

class MiniTest::Test

protected

  def produce(clazz)
    @started = srand

    Time.stub :now, Time.at(@started) do
      Scheduler.stub(:add, nil) do
        clazz.new
      end
    end
  end

  def interrupt!(type = :internal, pom = @pom)
    Scheduler.stub(:clear, nil) do
      pom.interrupt!(type)
    end
  end

  def finish!(thing = @pom || @break)
    Scheduler.stub(:clear, nil) do
      thing.finish!
    end
  end

  def cancel!(pom = @pom)
    Scheduler.stub(:clear, nil) do
      pom.cancel!
    end
  end
end

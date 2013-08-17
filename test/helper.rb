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

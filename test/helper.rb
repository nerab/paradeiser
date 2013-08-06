require 'minitest/autorun'
require 'paradeiser'
require_rel 'lib'

require 'lib/at_mock'

include Paradeiser

class MiniTest::Test

protected

  def start!(pom = @pom)
    Scheduler.stub(:add, nil) do
      pom.start!
    end
  end

  def finish!(pom = @pom)
    Scheduler.stub(:clear, nil) do
      pom.finish!
    end
  end
end

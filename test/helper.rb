require 'minitest/autorun'
require 'paradeiser'
require_rel 'lib'

include Paradeiser

class MiniTest::Test

protected

  def start!(pom = @pom)
    Scheduler.stub(:add, nil) do
      pom.start!
    end
  end
end

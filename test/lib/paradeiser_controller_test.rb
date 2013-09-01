require 'helper'

module ParadeiserTest
  # Not sure why Gurd seems to require this here ...
  class ControllerTest < UnitTest
  end

  class ParadeiserControllerTest < ControllerTest
    def model
      'paradeiser'
    end
  end
end

module Paradeiser
  class Start < Controller
    def index
      @msg = "Starting pomodoro"
    end

    def foo
      @msg = "Starting pomodoro 'foo' with args #{args}"
    end
  end
end

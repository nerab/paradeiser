module Paradeiser
  class SingletonError < StandardError
    def initialize(pom)
      super("Pomodoro #{pom.id} is already active.")
    end
  end

  class NoActivePomodoroError < StandardError
    def initialize
      super('There is no active pomodoro.')
    end
  end

  class NotInitializedError < StandardError
    def initialize(msg)
      super("Paradeiser was not properly initialized; #{msg}.")
    end
  end

  class IllegalStatusError < StandardError
    def initialize
      super('Idle pomodori cannot be saved.')
    end
  end

  class HookFailedError < StandardError
    def initialize(hook, out, err, status)
      super("The hook #{hook} failed with status #{status.exitstatus}. STDERR contained: #{err}")
    end
  end
end

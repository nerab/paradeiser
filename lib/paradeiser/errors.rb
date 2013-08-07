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

  class AlreadyInitializedError < StandardError
    def initialize(dir)
      super("Paradeiser was already initialized; #{dir} exists.")
    end
  end

  class IllegalStatusError < StandardError
    def initialize
      super('Idle pomodori cannot be saved.')
    end
  end
end

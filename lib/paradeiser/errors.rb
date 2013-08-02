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

  class ContradictingOptionsError < StandardError
    def initialize(*contradictions)
      super("The options #{contradictions.join(', ')} contradict each other.")
    end
  end
end

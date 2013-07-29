module Paradeiser
  class SingletonError < StandardError
    def initialize(pom)
      super("Pomodoro #{pom.id} is already active")
    end
  end

  class NoActivePomodoroError < StandardError
    def initialize
      super('There is no active pomodoro that could be finished')
    end
  end
end

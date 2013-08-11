module Paradeiser
  class PomodoriController < ScheduledController
    def start
      # The repository will protect itself, but we don't want to create
      # a new pomodoro if saving it will fail anyway.
      raise SingletonError.new(Repository.active) if Repository.active?

      @pom = Pomodoro.new
      @pom.start!
      Repository.save(@pom)
    end
  end
end

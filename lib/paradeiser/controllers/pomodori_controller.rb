module Paradeiser
  class PomodoriController < Controller
    def start
      # The repository will protect itself, but we don't want to create
      # a new pomodoro if saving it will fail anyway.
      raise SingletonError.new(Repository.active) if Repository.active?

      @pom = Pomodoro.new
      @pom.start!
      Repository.save(@pom)
    end

    def finish
      @pom = Repository.active
      raise NoActivePomodoroError unless @pom
      @pom.finish!
      Repository.save(@pom)
    end

    def report
      @pom = Repository.all
      self.has_output = true
    end

    def status
      if @pom = Repository.active
        self.exitstatus = 0
      elsif @pom = Repository.find{|pom| pom.finished?}.last
        self.exitstatus = 1
      # elsif Repository.find(:status => 'cancelled').last
      #   self.exitstatus = 2
      else
        @pom = Pomodoro.new # nothing found, we are idle
      end
      self.has_output = true
    end
  end
end

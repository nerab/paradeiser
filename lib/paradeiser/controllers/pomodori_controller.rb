module Paradeiser
  class PomodoriController < Controller
    def start
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
      self.verbose = true
    end

    def status
      if Repository.active
        self.exitstatus = 0
      elsif Repository.find_first(:status => 'finished')
        self.exitstatus = 1
      # elsif Repository.find_first(:status => 'cancelled')
      #   self.exitstatus = 2
      end
    end
  end
end

module Paradeiser
  class PomodoroController < Controller
    def start
      raise 'There already is an active pomodoro that is not yet finished.' if Repository.any?(:status => 'active')
      @pom = Pomodoro.new
      @pom.start!
      Repository.save(@pom)
    end

    def finish
      @pom = Repository.find_first(:status => 'active')
      raise 'There is no active pomodoro that could be finished' unless @pom
      @pom.finish!
      Repository.save(@pom)
    end

    def report
      @pom = Repository.all
    end
  end
end

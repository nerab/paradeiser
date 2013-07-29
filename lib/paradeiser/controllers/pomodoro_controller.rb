module Paradeiser
  SingletonError = Class.new(StandardError) do
    def message
      'There already is an active pomodoro that is not yet finished.'
    end
  end

  NoActivePomodoroError = Class.new(StandardError) do
    def message
      'There is no active pomodoro that could be finished'
    end
  end

  class PomodoroController < Controller
    def start
      raise SingletonError if Repository.any?(:status => 'active')
      @pom = Pomodoro.new
      @pom.start!
      Repository.save(@pom)
    end

    def finish
      @pom = Repository.find_first(:status => 'active')
      raise NoActivePomodoroError unless @pom
      @pom.finish!
      Repository.save(@pom)
    end

    def report
      @pom = Repository.all
    end
  end
end

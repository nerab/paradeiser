module Paradeiser
  class PomodoroController < Controller
    def start
      @pom = Pomodoro.new # TODO Lookup existing pomodoro
      @pom.start!
    end

    def finish
      @pom = Pomodoro.new # TODO Lookup existing pomodoro
      @pom.finish!
    end
  end
end

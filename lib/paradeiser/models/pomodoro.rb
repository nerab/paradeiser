module Paradeiser
  class Pomodoro < Scheduled
    MINUTES_25 = 25

    def length
      MINUTES_25 * 60
    end
  end
end

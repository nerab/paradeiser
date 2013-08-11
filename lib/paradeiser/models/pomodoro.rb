module Paradeiser
  class Pomodoro < Scheduled
    MINUTES_25 = 25

    def length
      raise NotActiveError unless active?
      MINUTES_25 * 60
    end
  end
end

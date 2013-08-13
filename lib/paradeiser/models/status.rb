module Paradeiser
  class Status
    MAP = {
      'pomodoro:active' => 0,
      'pomodoro:finished' => 1,
      'break:active' => 2,
      'break:finished' => 3,
    }

    def initialize(thing)
      @thing = thing
    end

    def to_i
      MAP[key] || -1
    end

  private

    def key
      "#{@thing.name}:#{@thing.status}"
    end
  end
end

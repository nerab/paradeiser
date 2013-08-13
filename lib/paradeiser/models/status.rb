module Paradeiser
  module Status

    MAP = {
      'pomodoro:active' => 0,
      'pomodoro:finished' => 1,
      'break:active' => 2,
      'break:finished' => 3,
    }

    def self.of(thing)
      thing.nil? ? -1 : MAP[key(thing)]
    end

  private

    def self.key(thing)
      "#{thing.name}:#{thing.status}"
    end
  end
end

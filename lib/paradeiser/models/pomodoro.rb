module Paradeiser
  class Pomodoro < Scheduled
    attr_reader :interrupts

    MINUTES_25 = 25

    def initialize
      super
      @interrupts = []
    end

    def length
      MINUTES_25 * 60
    end

    def interrupt(type = nil)
      @interrupts << Interrupt.new(type)
    end
  end
end

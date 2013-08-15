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
      Hook.new(:before).execute(self, :interrupt)
      @interrupts << Interrupt.new(type)
      Hook.new(:after).execute(self, :interrupt)
    end
  end
end

module Paradeiser
  class Pomodoro < Scheduled
    attr_reader :interrupts, :interrupt_type
    attr_accessor :canceled_at

    MINUTES_25 = 25

    state_machine :status, :initial => :idle do
      event :start do
        transition :idle => :active
      end

      event :interrupt do
        transition :active => :active
      end

      event :cancel do
        transition :active => :canceled
      end

      event :finish do
        transition :active => :finished
      end

      after_transition :on => :start do |pom, transition|
        pom.started_at = Time.now
        Scheduler.clear # There must be no other jobs scheduled because of Rule #1
        Scheduler.add(:"#{pom.name} finish", pom.length.minutes)
      end

      after_transition :on => :interrupt do |pom, transition|
        pom.interrupts << Interrupt.new(pom.interrupt_type)
      end

      around_transition do |pom, transition, block|
        Hook.new(:before).execute(pom, transition.event)
        block.call
        Hook.new(:after).execute(pom, transition.event)
      end

      after_transition :on => :cancel do |pom, transition|
        pom.canceled_at = Time.now
        Scheduler.clear # There must be no other jobs scheduled because of Rule #1
      end

      after_transition :on => :finish do |pom, transition|
        pom.finished_at = Time.now
        Scheduler.clear # There must be no other jobs scheduled because of Rule #1
      end
    end

    def initialize
      super # required for state_machine
      @interrupts = []
      start!
    end

    def length
      MINUTES_25 * 60
    end

    def interrupt!(type = nil)
      @interrupt_type = type
      super
    end
  end
end

module Paradeiser
  class Break < Scheduled

    state_machine :status, :initial => :idle do
      event :start do
        transition :idle => :active
      end

      event :finish do
        transition :active => :finished
      end

      after_transition :on => :start do |br3ak, transition|
        br3ak.started_at = Time.now
        Scheduler.clear # There must be no other jobs scheduled because of Rule #1
        Scheduler.add(:"#{br3ak.name} finish", br3ak.length.minutes)
      end

      around_transition do |br3ak, transition, block|
        Hook.new(:before).execute(br3ak, transition.event)
        block.call
        Hook.new(:after).execute(br3ak, transition.event)
      end

      after_transition :on => :finish do |br3ak, transition|
        br3ak.finished_at = Time.now
        Scheduler.clear # There must be no other jobs scheduled because of Rule #1
      end
    end

    def initialize(length = 300.seconds)
      super() # required for state_machine
      @length = length
      start!
    end

    def length
      @length
    end
  end
end

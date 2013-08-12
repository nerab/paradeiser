module Paradeiser
  class Scheduled
    attr_accessor :id, :started_at, :finished_at

    state_machine :status, :initial => :idle do
      event :start do
        transition :idle => :active
      end

      event :finish do
        transition :active => :finished
      end

      after_transition :on => :start do |pom, transition|
        pom.started_at = Time.now
        Scheduler.clear # There must be no other jobs scheduled because of Rule #1
        Scheduler.add(:finish, pom.length)
      end

      around_transition do |pom, transition, block|
        Hook.new(:before).execute(pom, transition)
        block.call
        Hook.new(:after).execute(pom, transition)
      end

      after_transition :on => :finish do |pom, transition|
        pom.finished_at = Time.now
        Scheduler.clear # There must be no other jobs scheduled because of Rule #1
      end
    end

    def initialize
      super # required for state_machine
    end

    def new?
      @id.nil?
    end

    # from https://github.com/travis-ci/travis/blob/master/lib/travis/client/job.rb
    def duration
      start  = started_at  || Time.now
      finish = finished_at || Time.now
      (finish - start).to_i
    end

    def remaining
      length - Time.now.to_i + started_at.to_i
    end

    def name
      self.class.name.split("::").last.downcase
    end
  end
end

module Paradeiser
  class Pomodoro
    LENGTH = 25 * 60

    attr_accessor :id, :started_at, :finished_at

    state_machine :status, :initial => :idle do
      event :start do
        transition :idle => :active
      end

      event :finish do
        transition :active => :finished
      end

      state :finished
      state :active
      state :idle

      after_transition :on => :start do |pom, transition|
        pom.started_at = Time.now
      end

      after_transition :on => :finish do |pom, transition|
        pom.finished_at = Time.now
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

    end
  end
end

module Paradeiser
  class ScheduledController < Controller
    def finish
      @pom = Repository.active
      raise NotActiveError unless @pom
      @pom.finish!
      Repository.save(@pom)
    end

    def report
      @pom = Repository.all
      self.has_output = true
    end

    def status
      if @pom = Repository.active
        self.exitstatus = 0
      elsif @pom = Repository.find{|pom| pom.finished?}.last
        self.exitstatus = 1
      # elsif Repository.find(:status => 'cancelled').last
      #   self.exitstatus = 2
      else
        @pom = Pomodoro.new # nothing found, we are idle
      end
      self.has_output = true
    end
  end
end

module Paradeiser
  class BreakController < ScheduledController
    def break
      raise SingletonError.new(Repository.active) if Repository.active?

      @pom = Break.new
      @pom.break!
      Repository.save(@pom)
    end
  end
end

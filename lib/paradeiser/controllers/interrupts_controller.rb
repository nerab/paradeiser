module Paradeiser
  class InterruptsController < Controller
    def create
      @pom = Repository.active
      raise NotActiveError unless @pom

      @pom.interrupt
      Repository.save(@pom)
    end
  end
end

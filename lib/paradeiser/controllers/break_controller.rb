module Paradeiser
  class BreakController < Controller
    def start
      raise SingletonError.new(Repository.active) if Repository.active?

      @break = Break.new
      @break.start!
      Repository.save(@break)
    end

    def finish
      @break = Repository.active
      raise NotActiveError unless @break
      @break.finish!
      Repository.save(@break)
    end
  end
end

module Paradeiser
  class BreakController < Controller
    def start
      raise SingletonError.new(Break, Repository.active, :start) if Repository.active?

      @break = Break.new
      @break.start!
      Repository.save(@break)
    end

    def finish
      @break = Repository.active
      raise NotActiveError unless @break
      raise SingletonError.new(Break, @break, :finish) if Repository.active? && Break != @break.class
      @break.finish!
      Repository.save(@break)
    end
  end
end

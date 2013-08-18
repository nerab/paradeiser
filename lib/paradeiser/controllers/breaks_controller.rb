module Paradeiser
  class BreaksController < Controller
    def start
      raise SingletonError.new(Break, Repository.active, :start) if Repository.active?

      @break = Break.new
      Repository.save(@break)
    end

    def finish
      @break = Repository.active
      raise NotActiveError unless @break
      raise SingletonError.new(Break, @break, :finish) if Repository.active? && !@break.kind_of?(Break)
      @break.finish!
      Repository.save(@break)
    end
  end
end

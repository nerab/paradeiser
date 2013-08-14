module Paradeiser
  class PomodoriController < Controller
    def start
      end_break
      raise SingletonError.new(Pomodoro, Repository.active, :start) if Repository.active?

      @pom = Pomodoro.new
      @pom.start!
      Repository.save(@pom)
    end

    def finish
      @pom = Repository.active
      raise NotActiveError unless @pom
      raise SingletonError.new(Pomodoro, @pom, :finish) if Repository.active? && Pomodoro != @pom.class
      @pom.finish!
      Repository.save(@pom)
    end

    def interrupt
      @pom = Repository.active
      raise NotActiveError unless @pom
      raise SingletonError.new(Pomodoro, @pom, :finish) if Repository.active? && Pomodoro != @pom.class

      @pom.interrupt
      Repository.save(@pom)
    end

  private

    def end_break
      if Repository.active?
        active = Repository.active

        if Break == active.class
          active.finish!
          Repository.save(active)
        end
      end
    end
  end
end

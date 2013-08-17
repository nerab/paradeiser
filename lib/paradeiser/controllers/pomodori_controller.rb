require 'active_support/core_ext/object/blank'

module Paradeiser
  class PomodoriController < Controller
    def start
      end_break
      raise SingletonError.new(Pomodoro, Repository.active, :start) if Repository.active?

      @pom = Pomodoro.new
      @pom.start!
      Repository.save(@pom)
    end

    def cancel
      @pom = Repository.active
      raise NotActiveError unless @pom
      raise SingletonError.new(Pomodoro, @pom, :finish) if Repository.active? && !@pom.kind_of?(Pomodoro)
      @pom.cancel!
      Repository.save(@pom)
    end

    def finish
      @pom = Repository.active
      raise NotActiveError unless @pom
      raise SingletonError.new(Pomodoro, @pom, :finish) if Repository.active? && !@pom.kind_of?(Pomodoro)
      @pom.finish!
      Repository.save(@pom)
    end

    def interrupt
      @pom = Repository.active
      raise NotActiveError unless @pom
      raise SingletonError.new(Pomodoro, @pom, :interrupt) if Repository.active? && !@pom.kind_of?(Pomodoro)

      if @options.external
        @interrupt_type = 'externally'
        @pom.interrupt!(:external)
      else
        @interrupt_type = 'internally'
        @pom.interrupt!
      end

      Repository.save(@pom)
    end

  private

    def end_break
      if Repository.active?
        active = Repository.active

        if active.kind_of?(Break)
          active.finish!
          Repository.save(active)
        end
      end
    end
  end
end

require 'fileutils'
#require 'action_view/helpers/text_helper'
require 'active_support/core_ext/enumerable'

module Paradeiser
  class ParadeiserController < Controller
    def init
      FileUtils.mkdir_p(Paradeiser.par_dir)
      FileUtils.cp_r(File.join(Paradeiser.templates_dir, Paradeiser.os.to_s, 'hooks'), Paradeiser.par_dir)
    end

    def report
      pomodori = Repository.all.select{|p| p.kind_of?(Pomodoro)}

      @finished = pomodori.select{|p| p.finished?}.size
      @canceled = pomodori.select{|p| p.canceled?}.size
      @external_interrupts = pomodori.map{|p| p.interrupts}.flatten.select{|i| :external == i.type}.size
      @internal_interrupts = pomodori.map{|p| p.interrupts}.flatten.select{|i| :internal == i.type}.size

      breaks = Repository.all.select{|b| b.kind_of?(Break)}
      @breaks = breaks.size
      @break_minutes = breaks.sum{|b| b.finished_at - b.started_at}.to_i.minutes

      self.has_output = true
    end

    def status
      @pom = Repository.active || Repository.all.last
      self.exitstatus = Status.of(@pom).to_i
      self.has_output = true

      #render(:text => 'There are no pomodori or breaks.') unless @pom
    end
  end
end

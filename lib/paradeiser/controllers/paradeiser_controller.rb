require 'fileutils'

module Paradeiser
  class ParadeiserController < Controller
    def init
      FileUtils.mkdir_p(Paradeiser.pom_dir)
      FileUtils.cp_r(File.join(Paradeiser.templates_dir, Paradeiser.os.to_s, 'hooks'), Paradeiser.pom_dir)
    end

    def report
      @pom = Repository.all
      self.has_output = true
    end

    def status
      if @pom = Repository.active
        self.exitstatus = 0
      elsif @pom = Repository.find{|p| p.finished?}.sort{|a,b| a.started_at <=> b.started_at}.last
        self.exitstatus = 1
      # elsif Repository.find(:status => 'cancelled').last
      #   self.exitstatus = 2
      end
      self.has_output = true
    end
  end
end

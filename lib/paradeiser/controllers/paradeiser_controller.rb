require 'fileutils'

module Paradeiser
  class ParadeiserController < Controller
    def init
      FileUtils.mkdir_p(Paradeiser.par_dir)
      FileUtils.cp_r(File.join(Paradeiser.templates_dir, Paradeiser.os.to_s, 'hooks'), Paradeiser.par_dir)
    end

    def report
      @pom = Repository.all
      self.has_output = true
    end

    def status
      @pom = Repository.active || Repository.last_finished
      self.exitstatus = Status.of(@pom).to_i
      self.has_output = true
    end
  end
end

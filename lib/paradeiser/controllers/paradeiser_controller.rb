require 'fileutils'

module Paradeiser
  class ParadeiserController < Controller
    def init
      FileUtils.mkdir_p(Paradeiser.pom_dir)
    end
  end
end

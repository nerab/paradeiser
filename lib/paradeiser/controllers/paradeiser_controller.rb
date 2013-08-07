require 'fileutils'

module Paradeiser
  class ParadeiserController < Controller
    def init
      raise AlreadyInitializedError.new(Paradeiser.pom_dir) if Dir.exists?(Paradeiser.pom_dir)
      FileUtils.mkdir_p(Paradeiser.pom_dir, 0700)
    end
  end
end

module Paradeiser
  class Job
    include Executor

    attr_reader :id

    JOB_PATTERN = %r{^pom .+$}

    def initialize(id)
      @id = id
    end

    def ==(other)
      id == other.id
    end

    def ours?
      exec("at -c #{@id}")[-2, 2].each do |line|
        if line
          return true if line.chomp.match(JOB_PATTERN)
        end
      end
    end
  end
end

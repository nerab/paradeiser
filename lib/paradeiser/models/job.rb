module Paradeiser
  class Job
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

  private

    # TODO Move this to a common place
    def exec(cmd)
      out, err, status = Open3.capture3(cmd)
      raise err if 0 < status.exitstatus
      [out, err]
    end
  end
end

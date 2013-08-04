require 'open3'

module Paradeiser
  class Scheduler
    class << self
      def list
        out, _ = exec("at -l -q #{queue}")

        out.lines.map do |line|
          id = parse_list(line)
          Job.new(id)
        end.select do |job|
          job.ours?
        end
      end

      def add(command, minutes)
        _, err = exec("echo pom #{command} | at -q #{queue} now + #{minutes} minutes")
        id = parse_add(err.chomp)
        Job.new(id)
      end

    private

      def parse_list(line)
        line[/^(\d+)/]
      end

      def parse_add(line)
        line.match(/^job (?<job>\d+)/)[:job]
      end

      def queue
        'p'
      end

      # TODO Move this to a common place
      def exec(cmd)
        out, err, status = Open3.capture3(cmd)
        raise err if 0 < status.exitstatus
        [out, err]
      end
    end
  end
end

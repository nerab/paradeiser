require 'open3'

module Paradeiser
  class Scheduler
    class << self
      include Executor

      def list
        out, _ = exec("#{at} -l -q #{queue}")

        out.lines.map do |line|
          id = parse_list(line)
          Job.new(id)
        end.select do |job|
          job.ours?
        end
      end

      def add(command, minutes)
        _, err = exec("echo pom #{command} | #{at} -q #{queue} now + #{minutes} minutes")
        id = parse_add(err.chomp)
        Job.new(id)
      end

      def clear
        if list.any? # On Linux, at must not be called with an empty job list.
          job_ids = list.map{|j| j.id}.join(' ')
          exec("#{at} -q #{queue} -r #{job_ids}")
        end
      end

    private

      def parse_list(line)
        line[/^(\d+)/]
      end

      def parse_add(line)
        line.match(/^job (?<job>\d+)/)[:job]
      end
    end
  end
end

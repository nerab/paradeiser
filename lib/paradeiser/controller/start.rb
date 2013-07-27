module Paradeiser
  module Controller
    class Start
      def call(args, options)
        STDERR.puts "Starting pomodoro" if options.verbose
      end
    end
  end
end

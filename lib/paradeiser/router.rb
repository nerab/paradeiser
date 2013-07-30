module Paradeiser
  class Router
    class << self
      def dispatch(command)
        Proc.new do |args, options|
          begin
            # TODO Dynamically find the controller that handles cmd.name
            PomodoriController.new(command.name).call(args, options)
          rescue
            $stderr.puts("Error: #{$!.message}")
            exit(1)
          end
        end
      end
    end
  end
end

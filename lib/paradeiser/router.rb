module Paradeiser
  class Router
    class << self
      def dispatch(command)
        Proc.new do |args, options|
          # TODO Dynamically find the controller that handles command.name
          controller = PomodoriController.new(command.name)

          begin
            controller.call(args, options)
          rescue
            $stderr.puts("Error: #{$!.message}")
            exit(1)
          end

          exit(controller.exitstatus)
        end
      end
    end
  end
end

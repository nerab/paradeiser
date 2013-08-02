module Paradeiser
  class Router
    class << self
      def dispatch(command)
        Proc.new do |args, options|
          method = command.name

          # TODO Dynamically find the controller that handles the method. :pomodoro is the default.
          controller = PomodoriController.new(method)

          begin
            controller.call(args, options)
          rescue
            $stderr.puts("Error: #{$!.message}")
            $stderr.puts $!.backtrace if options.trace
            exit(1)
          end

          View.new(controller.model, method).render(controller.get_binding) if options.verbose || controller.has_output

          exit(controller.exitstatus)
        end
      end
    end
  end
end

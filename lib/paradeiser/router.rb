module Paradeiser
  class Router
    attr_reader :status

    def initialize
      @status = 0
    end

    def dispatch(command)
      Proc.new do |args, options|
        method = command.name

        # TODO Dynamically find the controller that handles the method. :pomodoro is the default.
        if (:init == method.to_sym)
          controller_class = ParadeiserController
        elsif (:break == method.to_sym)
          controller_class = BreakController
        else
          controller_class = PomodoriController
        end

        controller = controller_class.new(method)
        controller.call(args, options)

        View.new(controller.model, method).render(controller.get_binding) if options.verbose || controller.has_output

        @status = controller.exitstatus
      end
    end
  end
end

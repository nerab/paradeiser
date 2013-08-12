module Paradeiser
  class Router
    attr_reader :status

    def initialize
      @status = 0
    end

    def dispatch(command)
      Proc.new do |args, options|
        parts = command.name.split
        resource = parts.shift
        controller_name = "#{resource.capitalize}Controller".to_sym

        if Paradeiser.const_defined?(controller_name)
          verb = parts.join
          controller_class = Paradeiser.const_get(controller_name)
        else
          verb = resource
          controller_class = ParadeiserController
        end

        controller = controller_class.new(verb)
        controller.call(args, options)

        View.new(controller.model, verb).render(controller.get_binding) if options.verbose || controller.has_output

        @status = controller.exitstatus
      end
    end
  end
end

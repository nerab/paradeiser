module Paradeiser
  class ControllerTest < MiniTest::Test
    def invoke(method, args = nil, options = nil, *attributes)
      controller = Paradeiser.const_get("#{model.pluralize.capitalize}Controller".to_sym).new(method)

      stdout, stderr = Repository.stub :backend, @backend do
        Scheduler.stub(:add, nil) do
          Scheduler.stub(:clear, nil) do
            capture_io do
              controller.call(Array(args), options)
            end
          end
        end
      end

      result = Hash[attributes.map do |e|
        [e.split('@').last.to_sym, controller.get_binding.eval(e)]
      end]

      result[:stdout] = stdout
      result[:stderr] = stderr
      result
    end
  end
end

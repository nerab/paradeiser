class ParadeiserControllerTest < MiniTest::Test

protected

  def invoke(method, *attributes)
    controller = ParadeiserController.new(method)

    stdout, stderr = Repository.stub :backend, @backend do
      Scheduler.stub(:add, nil) do
        Scheduler.stub(:clear, nil) do
          capture_io do
            controller.call(nil, nil)
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

class ParadeiserControllerTest < MiniTest::Test

protected

  def invoke(method, *attributes)
    controller = ParadeiserController.new(method)

    Repository.stub :backend, @backend do
      Scheduler.stub(:add, nil) do
        Scheduler.stub(:clear, nil) do
          controller.call(nil, nil)
        end
      end
    end

    Hash[attributes.map do |e|
      [e.split('@').last.to_sym, controller.get_binding.eval(e)]
    end]
  end
end

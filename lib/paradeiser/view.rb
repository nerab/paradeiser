module Paradeiser
  class View
    def initialize(model, method)
      @model, @method = model, method
    end

    def render(controller_binding)
      template.result(controller_binding)
    end

  private

    def template
      ERB.new(File.read(template_file), 0, '%<>')
    end

    def template_file
      File.join(File.dirname(__FILE__), 'views', @model.downcase, "#{@method}.erb")
    end
  end
end

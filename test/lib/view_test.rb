require 'helper'

module ParadeiserTest
  class ViewTest < UnitTest
    def render(method)
      View.new(model.pluralize, method).render(binding)
    end
  end

  class ParadeiserViewTest < ViewTest
    protected

    def model
      'Paradeiser'
    end
  end
end

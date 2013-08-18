class ViewTest < MiniTest::Test
  def render(method)
    View.new(model, method).render(binding)
  end
end

class ParadeiserViewTest < ViewTest
protected
  def model
    'Paradeiser'
  end
end

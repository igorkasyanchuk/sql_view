class AnotherView < SqlView::Model
  schema -> { User.where("age = 18") }

  extend_model_with do
    def test_instance_method
      42
    end
  end
end
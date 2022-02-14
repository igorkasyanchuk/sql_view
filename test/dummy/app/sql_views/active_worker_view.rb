class ActiveWorkerView < SQLView::Model
  schema -> { Worker.all }

  extend_model_with do
    belongs_to :jobable, polymorphic: true
  end
end

class MontherAnnaView < SqlView::Model

  schema -> {
    Mother.all
  }

  extend_model_with do
  end
end

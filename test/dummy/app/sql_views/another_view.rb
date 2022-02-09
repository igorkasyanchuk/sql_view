class AnotherView < SqlView::Model
  schema -> { User.where("age = 18") }
end
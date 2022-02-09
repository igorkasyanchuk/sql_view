class OldUserView < SqlView::Model
  self.view_name = "all_old_users"

  materialized

  schema -> { User.where("age > 18") }

  extend_model_with do
    scope :ordered, -> { order(:id) }
  end
end
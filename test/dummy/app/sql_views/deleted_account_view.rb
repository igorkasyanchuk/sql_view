class DeletedAccountView < SqlView::Model
  materialized

  schema -> { Account.none }

  extend_model_with do
    # sample how you can extend it, similar to regular AR model
    #
    # belongs_to :user
    # has_many :posts
    #
    # scope :ordered, -> { order(:created_at) }
    # scope :by_role, ->(role) { where(role: role) }
  end
end
